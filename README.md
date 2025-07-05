# Verification of AMBA AHB-Lite Protocol using UVM

This repository contains a comprehensive Universal Verification Methodology (UVM) environment for verifying an implementation of the AMBA AHB-Lite bus protocol. The project leverages SystemVerilog, UVM, and reference documentation to ensure protocol compliance and robust functional coverage.

---

## 📑 Project Report

For full methodology, results, and coverage analysis, see the main report:  
[UVM_AMBA_AHB_LITE_REPORT.pdf](documents/UVM_AMBA_AHB_LITE_REPORT.pdf)

---

## 📂 Repository Structure

- `/rtl` – RTL design files for AHB-Lite components (add description if present)
- `/dv` – UVM testbench and verification components
- `/illustrations` – Images used in the report
- `/documents` – Reference documents and project reports
  - [UVM_AMBA_AHB_LITE_REPORT.pdf](documents/UVM_AMBA_AHB_LITE_REPORT.pdf) – Main project report
  - [08_amba_ahb.pdf](documents/08_amba_ahb.pdf) – AMBA AHB protocol overview (sourced from [adki/AMBA_AXI_AHB_APB](https://github.com/adki/AMBA_AXI_AHB_APB/tree/master/slides))
  - [IHI0033C_amba_ahb_protocol_spec.pdf](documents/IHI0033C_amba_ahb_protocol_spec.pdf) – Official ARM protocol specification

---

## ✨ Features

- **UVM Testbench**: Full-featured, reusable verification environment
- **Protocol Coverage**: Functional coverage for AHB-Lite protocol features
- **Scoreboards and Monitors**: Automated checking and protocol compliance
- **Randomized and Directed Tests**: Ensures thorough scenario exploration
- **Reference Documentation**: Official ARM protocol specs included

---

## 🚀 Getting Started

1. **Clone the Repository**
   ```bash
   git clone https://github.com/AbdelrahmanYassien11/Verification-of-AMBA-AHB-LITE-using-UVM.git
   ```

2. **Explore the Folders**
   - Review the [project report](documents/UVM_AMBA_AHB_LITE_REPORT.pdf) for methodology and results
   - Browse `/rtl` and `/dv` for design and verification sources

3. **Simulate**
   - **There are three main ways to run simulations:**
     - 1) **Using the `run.do` file**
       - Run with:  
         ```bash
         vsim -do run.do
         ```
       - Edit `run.do` to specify which tests to run.
       - Coverage results ucdbs & txt files are saved for each `UVM_TESTNAME` executed.
     - 2) **Using the `/run_all_configs_all_tests` directory**
       - This approach employs a bash script that:
         - Uses the test names and bus widths that are defined inside it.
         - Edits the `.vh` header file accordingly.
         - Compiles the RTL & DV Environment using `log.do`.
         - Runs all the tests which are defined inside it.
         - Executes the corresponding `run_all_configs_all_tests.do` file which starts the respective test simulation.
         - **Outputs:** 
           - `/run_outputs` inside this directory, a folder with its name being the YYYYMMDD_HHMMSS format is created inside it are a number of subfolders:
             - `/compilation_logs` has the output log of the script's compilation for each configuration that was compiled.
             - `/simulation_logs` has the output log of the script's simulation for each configuration & test that has been run.
             - `/reports` contains the coverage report files for each test and the config that the test was run on, as well as the transcript respectively.
     - 3) **Using the `/run_all_tests_update_header_each_time_script` directory**
       - This method uses a `.do` file in combination with a bash script.
       - The script updates the project's header file to change bus widths before each test.
       - All test configurations (various bus widths) are executed automatically.
   - **Important Notes:**
     - Method 3 uses questa GuI (NOT IN BATCH MODE).
     - Methods 2 & 3 will run each test (`X_test`) for all available bus widths (32, 64, 128, 256, 512, 1024 bits).
     - This produces coverage results and transcripts for every configuration.
     - On machines with limited resources, reduce the number of widths or tests to avoid heavy workloads.
     - I don't recommend using method 3, its just old & I havent updated it in a while.
   - **General Simulation Steps:**
     - Use your preferred SystemVerilog/UVM simulator (e.g., ModelSim, QuestaSim).
     - Typical flow:
       ```bash
       cd dv
       vsim -do run.do
       ```

---

## 📚 References

- [AMBA AHB Protocol Specification](documents/IHI0033C_amba_ahb_protocol_spec.pdf) – Official ARM documentation
- [Project Report](documents/UVM_AMBA_AHB_LITE_REPORT.pdf)
- [AMBA AHB Protocol Overview](documents/08_amba_ahb.pdf) – Sourced from [adki/AMBA_AXI_AHB_APB GitHub repository](https://github.com/adki/AMBA_AXI_AHB_APB/tree/master/slides)

---

## 📫 Contact

- GitHub: [AbdelrahmanYassien11](https://github.com/AbdelrahmanYassien11)
- LinkedIn: [Abdelrahman Mohamad Yassien](https://www.linkedin.com/in/abdelrahman-mohamad-yassien)

---

For more details, methodology, and verification results, please read the full [project report](documents/UVM_AMBA_AHB_LITE_REPORT.pdf).