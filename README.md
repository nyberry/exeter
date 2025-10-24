# Health Data Science Resources

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://www.exeter.ac.uk/v8media/recruitmentsites/images/homepage/uoe-logo.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://www.exeter.ac.uk/v8media/recruitmentsites/images/homepage/uoe-logo.svg">
  <img alt="Exeter university logo." src="https://www.exeter.ac.uk/v8media/recruitmentsites/images/homepage/uoe-logo.svg">
</picture>

A personal collection of notebooks and helper scripts created during the MSc in Health Data Science at the
University of Exeter.

---

## Repository Structure


~~~
exeter-hds-resources/
├── notebooks/
│   ├── HPDM139/
│   └── HPDM172/
├── scripts/
├── data/
├── assets/
│   ├── images/
│   └── css/
├── docs/
└── misc/
~~~

---

## Quick Start

Clone the repository:

~~~bash
git clone https://github.com/nyberry/exeter.git
cd exeter
~~~

### Run notebooks locally

1. Create and activate a Conda or venv environment:

   ~~~bash
   conda create -n exeter python=3.12 jupyterlab
   conda activate exeter
   ~~~

2. Launch JupyterLab:

   ~~~bash
   jupyter lab
   ~~~

### Run notebooks remotely

(Mac IOs only) Use the included `scripts/start_jupyter.command` to connect securely to
Exeter Uni remote server and open JupyterLab in your local browser.

---

## Contents Highlights

- **Workshops:** class exercises with fully worked examples  
- **Assignments:** submitted coursework templates and analysis notebooks  
- **Scripts:** utilities for reproducible experiments and environment setup  
- **Docs:** quick-reference notes  

---

## Contributions

Pull requests and shared tips are welcome — please:

1. Use clear, descriptive filenames (`wk03_regression.ipynb`, not `new.ipynb`)
2. Keep large datasets out of Git (>10 MB)
3. Credit original authors or sources when reusing material

---

## ⚖️ License

Distributed under the MIT License.  
You are free to use, modify, and share these resources with attribution.

---

## 🏫 Acknowledgement

Created and maintained by Nick Berry
student
MSc in Health Data Science, University of Exeter (2025 cohort)
