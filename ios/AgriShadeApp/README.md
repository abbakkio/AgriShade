# AgriShade iOS Prototype (100% On-Device Core ML)

An on-device foliar pathology diagnostic application for iPhone, implementing the neural vision pipeline and agronomic decision support from `AgriShade.ipynb`.

---

## 🌟 Key Features

1. **100% On-Device Core ML (`AgriShadeNet.mlpackage` / `AgriShadeNet.mlmodelc`)**:
   - Zero internet connectivity required.
   - Runs directly on the **Apple Neural Engine (ANE)**, **GPU**, and **CPU**.
   - Classifies across all **38 PlantVillage pathology classes** spanning 14 agricultural crops.

2. **Botanical Taxon Resolution & Entropy Calculation**:
   - Resolves botanical crop family (`Rosaceae`, `Solanaceae`, `Poaceae`, `Vitaceae`, etc.).
   - Computes real-time **Shannon Entropy** to detect multi-disease ambiguity and out-of-distribution leaf inputs.
   - Checks crop genus consistency across top differential hypotheses.

3. **Clinical Fail-Safe Safety Lock (from `AgriShade.ipynb` Cell 6)**:
   - Evaluates:
     - Top-1 Posterior Confidence ($p_1 \ge 60\%$)
     - Confidence Margin ($\Delta p_1 - p_2 \ge 12\%$)
     - Maximum Entropy threshold ($\le 1.80$ nats)
     - Cross-crop taxon conflicts
   - When uncertainty is high, **chemical prescription is safely suppressed** with actionable guidance on recapturing leaf specimens.

4. **Clinical Agronomic Prescription Advisory**:
   - **Clinical Status**: Confirmed pathology state.
   - **Immediate Action**: Rapid foliar containment steps.
   - **Approved Chemical Protocol**: Curative / protective active ingredients with dosage guidelines.
   - **Organic / Biological Alternative**: Biofungicides (e.g., *Bacillus subtilis*), copper octanoate, sulfur, or compost extracts.
   - **Cultural Farm Hygiene**: Pruning, drip-irrigation transitions, and sanitization protocols.

5. **Lesion Contrast & Attention Engine**:
   - On-device contrast enhancement and necrotic tissue edge sharpening (mirroring the CIE-LAB CLAHE + Necrosis Index filter in the notebook) with an in-app toggle.

---

## 📱 How to Run on Your iPhone

### 1. Open in Xcode
Open the generated project directly:
```bash
open AgriShadeApp/AgriShade.xcodeproj
```

### 2. Connect Your iPhone & Sign
1. Connect your iPhone to your Mac via USB or Wi-Fi.
2. In Xcode, select the **AgriShade** project root in the left navigator.
3. Under the **Signing & Capabilities** tab:
   - Check **Automatically manage signing**.
   - Select your **Personal Team** (your free Apple ID).
   - If prompted, change the Bundle Identifier (e.g., `com.yourname.agrishade`).

### 3. Select Your iPhone Destination & Press Run (`⌘R`)
- In the top toolbar device selector, pick your connected iPhone.
- Press **Run** (`⌘R`).
- On your iPhone:
  - If running for the first time with a free developer certificate, go to **Settings > General > VPN & Device Management** and tap **Trust [Your Apple ID]**.
  - Also ensure **Developer Mode** is turned on (**Settings > Privacy & Security > Developer Mode**).

---

## 📁 Project Structure

```
AgriShadeApp/
├── AgriShade.xcodeproj/                 # Xcode Project
└── AgriShadeApp/
    ├── AgriShadeApp.swift               # App Lifecycle entry point
    ├── Info.plist                       # Camera & Photo Library permissions
    ├── AgriShadeNet.mlpackage           # Core ML Model Package (38 classes)
    ├── AgriShadeNet.mlmodelc/           # Pre-compiled Core ML Model bundle
    ├── Models/
    │   └── PathologyModel.swift         # Data structures, Botany Taxonomy & Advisory DB
    ├── Services/
    │   └── FoliarDiagnosticService.swift # Vision + CoreML + Entropy & Fail-Safe logic
    ├── Views/
    │   ├── ContentView.swift            # Main view, camera/photo picker, lesion toggle
    │   ├── DiagnosticReportCard.swift   # Pathology breakdown & Agronomic prescription card
    │   └── ImagePickerSheet.swift       # Camera / Gallery modal sheet
    └── Assets.xcassets/                 # App icon & assets catalog
```
