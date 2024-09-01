/******************************************************************
 * File: comparator.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11
 * Date: 25/08/2024
 * Description: This class is used to provide configuration to active agents
 
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Asynchronous FiFO project.
 * 

 ******************************************************************/


class active_agent_config;

  // Virtual interface used for connecting the active agent to the Design Under Test (DUT)
  virtual inf active_agent_config_my_vif;

  // Enumeration indicating whether the agent is active or passive
  protected uvm_active_passive_enum is_active;

  // Constructor for initializing the configuration object
  function new (virtual inf active_agent_config_my_vif, uvm_active_passive_enum is_active);
    // Set the virtual interface for the configuration
    this.active_agent_config_my_vif = active_agent_config_my_vif;
    // Set the active/passive state of the agent
    this.is_active = is_active;
  endfunction : new

  // Function to get the active/passive state of the agent
  function uvm_active_passive_enum get_is_active ();
    return is_active;
  endfunction : get_is_active

endclass : active_agent_config
