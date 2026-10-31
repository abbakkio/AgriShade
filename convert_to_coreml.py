import os
import urllib.request
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.models as models
import coremltools as ct

PLANTVILLAGE_38_CLASSES = [
    'Apple___Apple_scab', 'Apple___Black_rot', 'Apple___Cedar_apple_rust', 'Apple___healthy',
    'Blueberry___healthy', 'Cherry_(including_sour)___Powdery_mildew', 'Cherry_(including_sour)___healthy',
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot', 'Corn_(maize)___Common_rust_',
    'Corn_(maize)___Northern_Leaf_Blight', 'Corn_(maize)___healthy', 'Grape___Black_rot',
    'Grape___Esca_(Black_Measles)', 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)', 'Grape___healthy',
    'Orange___Haunglongbing_(Citrus_greening)', 'Peach___Bacterial_spot', 'Peach___healthy',
    'Pepper,_bell___Bacterial_spot', 'Pepper,_bell___healthy', 'Potato___Early_blight',
    'Potato___Late_blight', 'Potato___healthy', 'Raspberry___healthy', 'Soybean___healthy',
    'Squash___Powdery_mildew', 'Strawberry___Leaf_scorch', 'Strawberry___healthy',
    'Tomato___Bacterial_spot', 'Tomato___Early_blight', 'Tomato___Late_blight',
    'Tomato___Leaf_Mold', 'Tomato___Septoria_leaf_spot', 'Tomato___Spider_mites Two-spotted_spider_mite',
    'Tomato___Target_Spot', 'Tomato___Tomato_Yellow_Leaf_Curl_Virus', 'Tomato___Tomato_mosaic_virus',
    'Tomato___healthy'
]

CKPT_FILE = "mobilenetv3_s_plant_disease.pth"

class SoftmaxWrapper(nn.Module):
    def __init__(self, base_model):
        super().__init__()
        self.base_model = base_model

    def forward(self, x):
        logits = self.base_model(x)
        probs = F.softmax(logits, dim=1)
        return probs

def main():
    print("[*] Loading base MobileNetV3-Small...")
    base_model = models.mobilenet_v3_small(num_classes=38)
    state_dict = torch.load(CKPT_FILE, map_location="cpu")
    if isinstance(state_dict, dict) and "model_state_dict" in state_dict:
        state_dict = state_dict["model_state_dict"]
    base_model.load_state_dict(state_dict)
    base_model.eval()

    model = SoftmaxWrapper(base_model)
    model.eval()

    example_input = torch.randn(1, 3, 224, 224)
    print("[*] Tracing PyTorch model with Softmax wrapper...")
    traced_model = torch.jit.trace(model, example_input)

    print("[*] Converting to Core ML with ClassifierConfig...")
    image_input = ct.ImageType(
        name="input_leaf",
        shape=(1, 3, 224, 224),
        scale=1.0 / (255.0 * 0.226),
        bias=[-0.485 / 0.229, -0.456 / 0.224, -0.406 / 0.225],
        color_layout=ct.colorlayout.RGB
    )

    classifier_config = ct.ClassifierConfig(PLANTVILLAGE_38_CLASSES)

    mlmodel = ct.convert(
        traced_model,
        inputs=[image_input],
        classifier_config=classifier_config,
        minimum_deployment_target=ct.target.iOS16
    )

    mlmodel.author = "AgriShade Pathology Team"
    mlmodel.license = "Academic / Clinical Agronomy Prototype"
    mlmodel.short_description = "AgriShade foliar crop disease classifier (Softmax normalized probabilities 0..1)."
    mlmodel.input_description["input_leaf"] = "Input RGB leaf photo (224x224)"

    output_path = "AgriShadeNet.mlpackage"
    mlmodel.save(output_path)
    print(f"[✓] Saved updated Core ML model to {output_path}")

if __name__ == "__main__":
    main()
