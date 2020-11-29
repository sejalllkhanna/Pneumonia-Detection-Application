
import UIKit
import Vision
import CoreML

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    let imagePicker = UIImagePickerController()
      
      override func viewDidLoad() {
          super.viewDidLoad()
          imagePicker.delegate = self
          imagePicker.sourceType = .photoLibrary
          imagePicker.allowsEditing = false
        navigationItem.title = " Pneumonia Diagnosis 👨🏻‍⚕️🏨"
          
      }
      @IBOutlet weak var imageCapture:UIImageView!
      
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          
          if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage  {
              imageCapture.image = pickedImage
              guard let ciimage = CIImage(image: pickedImage) else { fatalError("Image is not converted")}
            filter(ciimage)
          }
          imagePicker.dismiss(animated: true, completion: nil)
          
          
      }
      func detectImage(image:CIImage) {
         guard let model = try? VNCoreMLModel(for:PneumoniaDetection().model)
              else{ fatalError("error in creating Model") }
        let disease = self.DetectionRequest(Model: model, Rimage: image)
        DispatchQueue.main.async {
            self.navigationItem.title = " Report  "
            if disease != "Normal" {
                self.sendAlert(title: "Diagnoed", message: " You have been Diagnosed with Pneumonia ", Buttontitle: "Consult Doctor")
            }
            else {
                self.sendAlert(title: "Nothing to worry ", message: " You Xray is Normal/ -tive to Pneumonia ", Buttontitle: "OK")
            }
        }
      }
    
    func filter(_ firstImage:CIImage) {
       guard let filterModel = try? VNCoreMLModel(for: Inceptionv3().model)
        else {
            fatalError("Inception Model Failed to Classify Image")
        }
        let filterOp = self.DetectionRequest(Model: filterModel, Rimage: firstImage)
        print(filterOp)
        if filterOp.contains("Isopod"){
            print("true case")
            detectImage(image: firstImage)
        }
        else {
            print("alert case")
            DispatchQueue.main.async {
                self.imageCapture.image = UIImage(systemName: "exclamationmark.triangle")
                self.sendAlert(title: "Worng Type of Image ", message: "provide only Chest Xray Images for the Detection", Buttontitle: "OK")
            }
        }
    }
      @IBAction func cameratapped(_ sender:UIBarButtonItem){
          
          present(imagePicker, animated: true, completion: nil)
          
      }
        
        func DetectionRequest(Model :VNCoreMLModel,Rimage:CIImage)->String
        {
            var output:String?
            
            
        let request = VNCoreMLRequest(model: Model) { (request, error) in
            let ans = request.results?.first as? VNClassificationObservation
            output = ans?.identifier.capitalized
                   }

                   let handler = VNImageRequestHandler(ciImage: Rimage)
                   do{
                   try handler.perform([request])
                   } catch {
                       print(error)
                   }
            return output!
            
        }
    
    func sendAlert(title:String,message:String,Buttontitle:String) {
        let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title:Buttontitle , style: .cancel, handler: nil))
                   self.present(alert,animated:true)
        
    }


}


