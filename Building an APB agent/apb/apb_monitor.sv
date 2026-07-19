class apb_monitor extends uvm_monitor implements apb_reset_handler;

    `uvm_component_utils(apb_monitor)

    apb_agent_config agent_config;

    uvm_analysis_port#(apb_item_mon) output_port;

    protected process process_collect_transactions;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        output_port = new("output_port", this);
    endfunction

    virtual task wait_reset_end();
        agent_config.wait_reset_end();
    endtask

    virtual task run_phase(uvm_phase phase);
        forever begin
            fork
                begin
                    wait_reset_end();
                    collect_transactions();

                    disable fork;
                end
            join
        end
    endtask

    protected virtual task collect_transactions();
        fork
            begin
                process_collect_transactions = process::self();
                forever begin 
                    collect_transaction();
                end
            end
        join
    endtask

    protected virtual task collect_transaction();
        apb_vif vif = agent_config.get_vif();

        apb_item_mon item = apb_item_mon::type_id::create("item");

        while(vif.psel !== 1) begin
            @(posedge vif.pclk);
            item.prev_item_delay++;
        end
        
        item.addr = vif.paddr;
        item.dir = apb_dir'(vif.pwrite);
        item.length = 1;

        if(item.dir == APB_WRITE) begin
            item.data = vif.pwdata;
        end

        @(posedge vif.pclk);
        item.length++;

        while(vif.pready !== 1) begin
            @(posedge vif.pclk);
            item.length++;
            if(agent_config.get_has_checks())begin
                if(item.length >= agent_config.get_stuck_threshold()) begin
                    `uvm_error("PROTOCOL_ERROR", $sformatf("The APB transfer reached the stuck threshold value of %0d", item.length))
                end
            end
        end

        item.response = apb_response'(vif.pslverr);

        if(item.dir == APB_READ) begin
            item.data = vif.prdata;
        end
        
        output_port.write(item);

        `uvm_info("DEBUG", $sformatf("monitored item: %0s", item.convert2string()), UVM_NONE)

        @(posedge vif.pclk);

    endtask

    virtual function void handle_reset(uvm_phase phase);
        if(process_collect_transactions != null) begin
            process_collect_transactions.kill();
            process_collect_transactions = null;
        end
    endfunction

endclass
