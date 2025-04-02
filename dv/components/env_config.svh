/******************************************************************
 * File: env_config.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This class defines the configuration object for the
 *              environment in a UVM testbench. It holds the virtual
 *              interface used by the environment components and
 *              provides a method for initializing the configuration.
 * 
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 ******************************************************************/

class env_config;

  // Virtual interface to the DUT
  virtual inf env_config_my_vif;

  // Constructor for the configuration class
  function new(virtual inf env_config_my_vif);
    // Initialize the virtual interface
    this.env_config_my_vif = env_config_my_vif;
  endfunction : new

endclass : env_config
