import UIKit
import PhotosUI
import UniformTypeIdentifiers
import ImageIO
import CoreLocation
import MapKit
import AVFoundation

class TaskDetailViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    private var task: Task
    var onSave: ((Task) -> Void)?

    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()
    private let imageView = UIImageView()
    private let mapView = MKMapView()
    private let attachButton = UIButton(type: .system)
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Task"

        mapView.delegate = self

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = task.title
        view.addSubview(titleLabel)

        detailsLabel.numberOfLines = 0
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.text = task.details
        view.addSubview(detailsLabel)

        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.secondaryLabel.cgColor
        imageView.layer.borderWidth = 1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        attachButton.setTitle("Attach Photo", for: .normal)
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.addTarget(self, action: #selector(attachPhotoTapped), for: .touchUpInside)
        view.addSubview(attachButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            imageView.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            attachButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            attachButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            mapView.topAnchor.constraint(equalTo: attachButton.bottomAnchor, constant: 12),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 200)
        ])

        refreshUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Clear image from memory when low on memory
        // It will be reloaded from disk when needed
        imageView.image = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // When navigating away, save and clear transient data
        if isMovingFromParent {
            // Clear image from view to free memory
            imageView.image = nil
        }
    }
    
    deinit {
        // Stop location updates when deallocated
        locationManager.stopUpdatingLocation()
    }

    private func refreshUI() {
        titleLabel.text = task.title + (task.completed ? " ✅" : "")
        detailsLabel.text = task.details
        
        // Free previous image memory before loading new one
        imageView.image = nil
        
        // Load image efficiently using cache
        if let img = task.uiImage() {
            imageView.image = img
        }

        // Update map with thumbnail to save memory
        mapView.removeAnnotations(mapView.annotations)
        if let c = task.coordinate {
            let coord = CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude)
            // Use small thumbnail for map annotation to save memory
            let thumb = task.thumbnailImage(maxSize: CGSize(width: 60, height: 60))
            let ann = TaskAnnotation(taskId: task.id, coordinate: coord, title: task.title, subtitle: task.details, thumbnail: thumb)
            mapView.addAnnotation(ann)
            let region = MKCoordinateRegion(center: coord, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: false)
            mapView.selectAnnotation(ann, animated: true)
        }
    }

    @objc private func attachPhotoTapped() {
        let sheet = UIAlertController(title: "Attach Photo", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { [weak self] _ in
            var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            config.filter = .images
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            self?.present(picker, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // For iPad: anchor
        if let p = sheet.popoverPresentationController {
            p.sourceView = attachButton
            p.sourceRect = attachButton.bounds
        }
        present(sheet, animated: true)
    }

    // MARK: - Camera
    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentAlert(title: "No Camera", message: "Camera is not available on this device.")
            return
        }

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            // Start a short location update so we can tag the photo if possible
            startLocationIfNeeded()
            showCameraPicker()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.startLocationIfNeeded()
                        self?.showCameraPicker()
                    } else {
                        self?.presentCameraDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            presentCameraDeniedAlert()
        @unknown default:
            presentCameraDeniedAlert()
        }
    }

    private func showCameraPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.cameraCaptureMode = .photo
        present(picker, animated: true)
    }

    private func startLocationIfNeeded() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            lastLocation = locationManager.location
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        case .denied, .restricted:
            // No location available
            break
        @unknown default:
            break
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            lastLocation = loc
        }
        // stop further updates to preserve battery
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // ignore or log
        print("Location manager failed: \(error)")
    }

    private func presentCameraDeniedAlert() {
        let alert = UIAlertController(title: "Camera Access Denied", message: "Please enable camera access in Settings → Privacy → Camera", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    // MARK: - PHPicker Delegate (Photo Library Only)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        let provider = result.itemProvider
        let imageType = UTType.image.identifier

        if provider.hasItemConformingToTypeIdentifier(imageType) {
            // Use loadFileRepresentation for better memory efficiency
            provider.loadFileRepresentation(forTypeIdentifier: imageType) { [weak self] (fileUrl, error) in
                guard let self = self else { return }
                if let error = error {
                    print("loadFileRepresentation error: ", error)
                    return
                }
                guard let fileUrl = fileUrl else { return }

                // Process image data and metadata efficiently
                self.processImageFromLibrary(url: fileUrl)
            }
        }
    }
    
    // Memory-efficient image processing from photo library
    private func processImageFromLibrary(url: URL) {
        // Create a temporary copy to work with
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.removeItem(at: tmp)
        
        do {
            try FileManager.default.copyItem(at: url, to: tmp)
        } catch {
            print("Failed to copy image: \(error)")
            return
        }
        
        defer {
            // Clean up temporary file
            try? FileManager.default.removeItem(at: tmp)
        }
        
        // Parse metadata first (before loading full image data)
        var coordinate: Task.Coordinate?
        if let src = CGImageSourceCreateWithURL(tmp as CFURL, nil),
           let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] {
            if let gps = props[kCGImagePropertyGPSDictionary] as? [CFString: Any],
               let coord = TaskDetailViewController.coordinateFromGPSDictionary(gps) {
                coordinate = Task.Coordinate(latitude: coord.latitude, longitude: coord.longitude)
            }
        }
        
        // Load and compress image data to reduce memory footprint
        if let imageData = try? Data(contentsOf: tmp),
           let image = UIImage(data: imageData) {
            // Compress to reasonable quality for storage
            if let compressedData = image.jpegData(compressionQuality: 0.7) {
                self.task.imageData = compressedData
            }
        }
        
        // Set coordinate if found
        if let coord = coordinate {
            self.task.coordinate = coord
        }
        
        // Mark completed
        self.task.completed = true

        DispatchQueue.main.async {
            self.refreshUI()
            self.onSave?(self.task)
        }
    }

    // MARK: - UIImagePickerControllerDelegate (camera)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        // Try to obtain metadata if available (only for camera capture)
        let metadata = info[.mediaMetadata] as? [String: Any]

        var finalData: Data?
        // Build metadata dictionary and include GPS if we have lastLocation
        var metaDict = metadata ?? [:]
        if let loc = lastLocation {
            var gps = [CFString: Any]()
            let coord = loc.coordinate
            gps[kCGImagePropertyGPSLatitude] = fabs(coord.latitude)
            gps[kCGImagePropertyGPSLatitudeRef] = coord.latitude >= 0 ? "N" : "S"
            gps[kCGImagePropertyGPSLongitude] = fabs(coord.longitude)
            gps[kCGImagePropertyGPSLongitudeRef] = coord.longitude >= 0 ? "E" : "W"
            if loc.altitude != 0 {
                gps[kCGImagePropertyGPSAltitude] = loc.altitude
                gps[kCGImagePropertyGPSAltitudeRef] = loc.altitude < 0 ? 1 : 0
            }
            // Timestamp in UTC
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "UTC")
            formatter.dateFormat = "HH:mm:ss.SSSSSS"
            gps[kCGImagePropertyGPSTimeStamp] = formatter.string(from: loc.timestamp)

            // Merge into metaDict under kCGImagePropertyGPSDictionary
            metaDict[kCGImagePropertyGPSDictionary as String] = gps
        }

        // Combine UIImage CGImage and metadata into JPEG data using ImageIO
        if let cgImage = image.cgImage {
            let mutableData = CFDataCreateMutable(nil, 0)!
            guard let dst = CGImageDestinationCreateWithData(mutableData, UTType.jpeg.identifier as CFString, 1, nil) else {
                finalData = image.jpegData(compressionQuality: 0.7) // Reduced from 0.9
                self.storeCaptured(imageData: finalData, metadataSourceData: finalData)
                return
            }
            let cfMeta = metaDict as CFDictionary
            CGImageDestinationAddImage(dst, cgImage, cfMeta)
            if CGImageDestinationFinalize(dst) {
                finalData = mutableData as Data
            } else {
                finalData = image.jpegData(compressionQuality: 0.7) // Reduced from 0.9
            }
        } else {
            finalData = image.jpegData(compressionQuality: 0.7) // Reduced from 0.9
        }

        storeCaptured(imageData: finalData, metadataSourceData: finalData)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func storeCaptured(imageData: Data?, metadataSourceData: Data?) {
        if let data = imageData {
            self.task.imageData = data
        }

        // Parse metadata for GPS from the data blob
        if let d = metadataSourceData,
           let src = CGImageSourceCreateWithData(d as CFData, nil),
           let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any],
           let gps = props[kCGImagePropertyGPSDictionary] as? [CFString: Any],
           let coord = TaskDetailViewController.coordinateFromGPSDictionary(gps) {
            self.task.coordinate = Task.Coordinate(latitude: coord.latitude, longitude: coord.longitude)
        }

        // Mark completed
        self.task.completed = true

        DispatchQueue.main.async {
            self.refreshUI()
            self.onSave?(self.task)
        }
    }

    // Copied helper from earlier to parse GPS
    static func coordinateFromGPSDictionary(_ gps: [CFString: Any]) -> CLLocationCoordinate2D? {
        func doubleFrom(_ value: Any?) -> Double? {
            if let d = value as? Double { return d }
            if let s = value as? String { return Double(s) }
            if let num = value as? NSNumber { return num.doubleValue }
            return nil
        }
        guard let latVal = doubleFrom(gps[kCGImagePropertyGPSLatitude]),
              let latRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
              let lonVal = doubleFrom(gps[kCGImagePropertyGPSLongitude]),
              let lonRef = gps[kCGImagePropertyGPSLongitudeRef] as? String else {
            return nil
        }
        var latitude = latVal
        var longitude = lonVal
        if latRef.uppercased() == "S" { latitude = -latitude }
        if lonRef.uppercased() == "W" { longitude = -longitude }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - TaskAnnotation and Map Delegate
final class TaskAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let taskId: UUID
    let thumbnail: UIImage?

    init(taskId: UUID, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String? = nil, thumbnail: UIImage? = nil) {
        self.taskId = taskId
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.thumbnail = thumbnail
        super.init()
    }
}

// MARK: - MKMapViewDelegate
extension TaskDetailViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        if let taskAnn = annotation as? TaskAnnotation {
            let id = "TaskAnnotationView"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
            if view == nil {
                view = MKMarkerAnnotationView(annotation: taskAnn, reuseIdentifier: id)
                view?.canShowCallout = true
                view?.clusteringIdentifier = "task"
                // left callout: thumbnail
                let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
                iv.contentMode = .scaleAspectFill
                iv.clipsToBounds = true
                view?.leftCalloutAccessoryView = iv
                view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            view?.annotation = taskAnn
            view?.markerTintColor = .systemBlue
            if let thumb = taskAnn.thumbnail {
                // set small glyph or set callout image
                view?.glyphImage = thumb
                if let iv = view?.leftCalloutAccessoryView as? UIImageView {
                    iv.image = thumb
                }
            } else {
                view?.glyphImage = nil
            }
            return view
        }

        // fallback
        let pinId = "Pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let taskAnn = view.annotation as? TaskAnnotation {
            // Present a full-screen image viewer if we have the task's image
            if taskAnn.taskId == task.id, let img = task.uiImage() {
                let vc = ImageViewerViewController(image: img)
                present(vc, animated: true)
                return
            }
            // Fallback: log
            print("Tapped callout for task: \(taskAnn.taskId)")
        }
    }
}
