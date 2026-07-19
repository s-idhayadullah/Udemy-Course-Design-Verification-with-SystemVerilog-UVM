class apb_agent extends uvm_agent implements apb_reset_handler;

    `uvm_component_utils(apb_agent)

    apb_vif vif;
    apb_agent_config agent_config;

    apb_sequencer sequencer;
    apb_driver driver;

    apb_monitor monitor;
    apb_coverage coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent_config = apb_agent_config::type_id::create("agent_config", this);

        monitor = apb_monitor::type_id::create("monitor", this);

        if(agent_config.get_has_coverage()) begin
            coverage = apb_coverage::type_id::create("apb_monitor", this);
        end

        if(agent_config.get_is_active() == UVM_ACTIVE) begin
            sequencer = apb_sequencer::type_id::create("sequencer", this);
            driver = apb_driver::type_id::create("driver", this);
        end
    endfunction


    function void connect_phase(uvm_phase phase);
        string vif_name = "vif";
        if(uvm_config_db#(apb_vif)::get(this, "", "vif", vif) == 0) begin 
            `uvm_fatal("APB_NO_VIF", $sformatf("Could not get from the database the APB virtual interface using name \"%0s\"", vif_name))
        end
        else begin
            agent_config.set_vif(vif);
        end

        monitor.agent_config = agent_config;

        if(agent_config.get_is_active() == UVM_ACTIVE) begin
            driver.agent_config = agent_config;

            driver.seq_item_port.connect(sequencer.seq_item_export);
        end

        if(agent_config.get_has_coverage()) begin
            coverage.agent_config = agent_config;

            monitor.output_port.connect(coverage.port_item);
        end

    endfunction


    virtual function void handle_reset(uvm_phase phase);
        uvm_component children[$];

        get_children(children);

        foreach(children[idx]) begin
            apb_reset_handler reset_handler;    

            if($cast(reset_handler, children[idx])) begin
                reset_handler.handle_reset(phase);
            end
        end
    endfunction

    virtual task wait_reset_start();
        agent_config.wait_reset_start();
    endtask

    virtual task wait_reset_end();
        agent_config.wait_reset_end();
    endtask


    virtual task run_phase(uvm_phase phase);
        forever begin
            wait_reset_start();
            handle_reset(phase);
            wait_reset_end();
        end
    endtask

endclass
