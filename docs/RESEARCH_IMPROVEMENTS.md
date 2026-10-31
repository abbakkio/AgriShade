# Comprehensive Research & Improvement Plan: AgriShade Pathology System
*Based on the findings and 6 recommendations in `report.md`*

---

## Executive Summary & Root Cause Analysis

The evaluation in `report.md` tested the application with 5 plant specimens (Rubber Plant, Spider Plant, Peace Lily, and Grape leaf with spots) and identified critical vulnerabilities:
1. **4 out of 5 tests produced incorrect species classifications** (e.g. Spider Plant classified as Bell Pepper with 80.4% confidence).
2. **Confidence values were deceptive**: High confidence (80.4%) occurred on completely unsupported indoor/ornamental species.
3. **The Fail-Safe was praised**: The fail-safe lock successfully triggered across all 5 test cases, validating the architectural safeguard designed in `AgriShade.ipynb`.
4. **Lesion Heatmaps lacked contrast/evidence**: The user could not observe clear visual evidence of lesion localization.

### Fundamental Diagnostic: The Closed-World Dilemma
The underlying MobileNetV3 model was trained solely on **PlantVillage** (54,305 lab images of 14 agricultural crops). When presented with a houseplant (Peace Lily, Ficus, Chlorophytum), the model operates in a closed-world space: it is mathematically forced to distribute probability across its 38 agricultural classes. Because green foliage shares basic pigment and texture features with bell pepper leaves, standard Softmax produces high confidence for an out-of-domain plant.

---

## Architectural Roadmap: 5 Core Improvement Pillars

```
                        [ In-Field Photo Capture ]
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ STAGE 1: Hierarchical Two-Stage Pipeline (Priority 1 & 2)              │
│                                                                        │
│   Step 1.1: General Botanical Gatekeeper                               │
│             Is this an agricultural crop, houseplant, or non-plant?    │
│             (Apple Vision Taxonomy / MobileNet-V4 Crop Classifier)     │
│                                                                        │
│   Step 1.2: Host Crop Verification (14 Supported Genera)               │
│             If Crop ∉ {Apple, Tomato, Grape, Corn, Pepper, ...}:       │
│             ──► Return "Unsupported Ornamental / Non-Target Species"   │
│             ──► Suppress pathology diagnosis entirely                  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Crop Confirmed (e.g. "Grape")
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ STAGE 2: Species-Conditioned Pathology Inference                       │
│                                                                        │
│   Step 2.1: Route exclusively to Grape disease heads (4 classes)       │
│             • Black Rot                                                │
│             • Esca (Black Measles)                                     │
│             • Isariopsis Leaf Spot                                     │
│             • Healthy                                                  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ STAGE 3: Energy-Based OOD & Calibrated Uncertainty (Priority 3)        │
│                                                                        │
│   • Free Energy Score: $E(x; T) = -T \cdot \log \sum e^{f_i(x)/T}$     │
│   • Temperature-Scaled Confidence: $\hat{p}_i = \text{Softmax}(z_i / T)│
│   • Display Dual Metrology:                                            │
│     (1) Species Match Certainty vs. (2) Pathology Diagnosis Severity   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ STAGE 4: On-Device Grad-CAM Lesion Heatmap Overlay (Priority 5)        │
│                                                                        │
│   • Core ML Multi-Head Export (features + logits)                      │
│   • Weight spatial activation maps by gradients on device              │
│   • Thermal Jet colormap over actual necrotic lesions                  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Detailed Improvement Strategy

### 1. Two-Stage Decoupled Pipeline (Solving Priority 1 & 2)
Currently, the model predicts both the crop and the disease in a single flat vector (e.g. `Pepper,_bell___healthy` vs `Corn_(maize)___healthy`). 

**The Solution:**
* **Stage 1 (Crop Classifier)**: A dedicated classifier trained on broad plant families (or using a MobileNetV4 backbone fine-tuned on the *PlantNet* / *iNaturalist* open flora dataset). 
* **Stage 2 (Pathology Classifier)**: Only activates if Stage 1 confirms the specimen belongs to one of the 14 supported agricultural crops.
* **Immediate Mobile Implementation (Zero-Retraining Hack)**:
  Aggregate the 38 classes into **14 Crop Marginal Probabilities**:
  $$P(\text{Crop} = c) = \sum_{k \in \text{Diseases}(c)} P(k)$$
  If the maximum marginal crop probability is below $75\%$ or if the top 3 crops are scattered (e.g., Pepper 30%, Tomato 25%, Corn 20%), the app returns:
  > **"Unsupported Plant Species: This specimen does not appear to be one of the 14 supported agricultural crops (e.g. Spider Plant, Ficus, or non-crop foliage detected)."**

---

### 2. Temperature Scaling & Energy-Based OOD Detection (Solving Priority 3)
Standard Softmax is notorious for producing overconfident probabilities on out-of-distribution data because the denominator normalizes any set of logits into $[0, 1]$.

#### A. Free Energy OOD Score
Instead of using max softmax probability, calculate **Helmholtz Free Energy**:
$$E(x; T) = -T \cdot \log \sum_{i=1}^{K} \exp\left(\frac{z_i}{T}\right)$$
- In-distribution agricultural leaves have low energy (high negative values: $-40$ to $-60$).
- Out-of-distribution indoor plants (Rubber plant, Peace lily) have high energy ($-5$ to $-15$).
- By setting an energy threshold $\tau_{\text{energy}}$, any non-target plant is rejected *regardless* of what the relative Softmax ranking suggests.

#### B. Confidence Decomposition in UI
In [`DiagnosticReportCard.swift`](file:///Users/azatmadiyev/Data/AITU/1.1/ICT/Assignment_4/AgriShadeApp/AgriShadeApp/Views/DiagnosticReportCard.swift), replace the single "Confidence: 80.4%" badge with two distinct metrics:
1. **Botanical Species Match**: e.g., "Grape (88% Match)"
2. **Diagnostic Severity Certainty**: e.g., "Isariopsis Spot (72% Typicality)"

---

### 3. Improving Explainability & Lesion Attention (Solving Priority 5)
In `report.md`, the author noted that the lesion overlay was hard to interpret.

**Actionable Enhancements**:
1. **Dynamic High-Contrast Bounding Box / Contour Highlights**:
   - Rather than just a translucent color blend, apply an OpenCV-style morphological edge detector that draws an explicit pulsating yellow/red contour around the actual necrotic circles.
2. **Side-by-Side Split Slider View**:
   - Allow the user to drag a split bar across the leaf photo to compare the raw sensor image against the CLAHE-normalized lesion map.
3. **Core ML Activation Extraction**:
   - Export the model with two outputs: `logits` and the final feature map `Conv_1` ($7 \times 7 \times 960$). Compute the true class activation map directly inside Swift via Accelerate framework.

---

### 4. Expanding Training Dataset to "In-The-Wild" (Solving Priority 4 & 6)
PlantVillage images were taken in laboratory settings on neutral grey paper backgrounds with detached leaves. Real field usage involves:
- Dappled sunlight, shadow fringes, and overexposure.
- Background soil, weeds, stems, and hands holding the leaf.
- Unrelated ornamental plants nearby.

**Action Plan**:
1. Mix PlantVillage with **PlantDoc** (a dataset of real-world field images with natural backgrounds).
2. Add an explicit **negative/clutter class** (1,000 images of common houseplants, weeds, and hands) labelled `NonTarget_Foliage`. When a user submits a Ficus or Spider plant, the model will actively classify it as `NonTarget_Foliage` rather than forcing it into `Pepper,_bell`.

---

## Action Plan & Immediate Quick-Wins

| Step | Scope | Impact |
|---|---|---|
| **1. Crop Marginal Gating (iOS)** | Swift / UI | Immediately prevents Spider Plant from showing "Bell Pepper (80%)"; flags it as Unsupported Species. |
| **2. Dual Metric UI (iOS)** | Swift | Displays separate Botanical Match and Pathology Confidence so users aren't misled. |
| **3. Energy OOD Filter (iOS)** | Swift / Core ML | Rejects out-of-distribution ornamental plants using log-sum-exp energy. |
| **4. Negative Class Retraining (Python)** | Notebook | Adds background/houseplants to the PyTorch training set in `AgriShade.ipynb`. |
| **5. High-Contrast Contour Engine (iOS)** | Vision / Metal | Sharpens lesion spots so diseased patches clearly pop in the Cell 6 dashboard. |
