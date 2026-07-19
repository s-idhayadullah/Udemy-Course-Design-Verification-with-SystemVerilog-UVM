class apb_agent_config extends uvm_component;

    `uvm_component_utils(apb_agent_config)

    local apb_vif vif;

    local uvm_active_passive_enum is_active;

    //switch to enable checks
    local bit has_checks;

    //switch to enable coverage
    local bit has_coverage;

    //maximum clock cycle threshold for a transfer
    local int unsigned stuck_threshold; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
        is_active = UVM_ACTIVE;
        has_checks = 1;
        has_coverage = 1;
        stuck_threshold = 1000;
    endfunction

    virtual function apb_vif get_vif();
        return vif;
    endfunction

    virtual function void set_vif(apb_vif value);
        if(vif == null) begin
            vif = value;

            set_has_checks(get_has_checks());
        end
        else begin
            `uvm_fatal("ALGORITHM_ISSUE", "Trying to set the APB virtual interface more than once")
        end
    endfunction

    virtual function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction

    virtual function void set_is_active(uvm_active_passive_enum value);
        is_active = value;
    endfunction

    virtual function bit get_has_checks();
        return has_checks;
    endfunction

    virtual function void set_has_checks(bit value);
        has_checks = value;

        if(vif != null) begin
            vif.has_checks = has_checks;
        end
    endfunction

    virtual function bit get_has_coverage();
        return has_coverage;
    endfunction

    virtual function void set_has_coverage(bit value);
        has_coverage = value;
    endfunction

    virtual function int unsigned get_stuck_threshold();
        return stuck_threshold;
    endfunction

    virtual function void set_stuck_threshold(int unsigned value);
        if(value <= 2) begin
            `uvm_error("ALGORITHM_ISSUE", $sformatf("Tried to set stuck_threshold to value %d but the minimum length of an APB transfer is 2", value))
        end
      
        stuck_threshold = value;
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
      
        if(get_vif() == null) begin
            `uvm_fatal("ALGORITHM_ISSUE", "The APB virtual interface is not configured at \"Start of simulation\" phase")
        end
        else begin
            `uvm_info("APB_CONFIG", "The APB virtual interface is configured at \"Start of simulation\" phase", UVM_DEBUG)
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        @(vif.has_checks);

        if(vif.has_checks != has_checks) begin
            `uvm_error("ALGORITHM_ISSUE", $sformatf("Can not change \"has_checks\" from APB interface directly - use %0s.set_has_checks()", get_full_name()))
        end

    endtask


    virtual task wait_reset_start();
        if(vif.preset_n !== 0) begin
            @(negedge vif.preset_n);
        end
    endtask

    virtual task wait_reset_end();
        while(vif.preset_n === 0) begin
            @(posedge vif.pclk);
        end
    endtask

endclass
