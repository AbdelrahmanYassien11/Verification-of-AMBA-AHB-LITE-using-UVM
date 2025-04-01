/******************************************************************
 * File: passive_agent_config.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This class defines the configuration for the passive
 *              agent in a UVM testbench. It includes a virtual interface
 *              for interacting with the DUT and a flag to determine 
 *              whether the agent is passive or active.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class passive_agent_config;

  // Virtual interface for the passive agent configuration
  virtual inf passive_agent_config_my_vif;

  // Enum to define if the agent is passive or active
  protected uvm_active_passive_enum is_passive;

  // Constructor for the passive_agent_config class
  function new (virtual inf passive_agent_config_my_vif, uvm_active_passive_enum is_passive);
    this.passive_agent_config_my_vif = passive_agent_config_my_vif;
    this.is_passive = is_passive;
  endfunction : new

  // Function to get the passive/active status of the agent
  function uvm_active_passive_enum get_is_passive ();
    return is_passive;
  endfunction : get_is_passive

endclass : passive_agent_config
