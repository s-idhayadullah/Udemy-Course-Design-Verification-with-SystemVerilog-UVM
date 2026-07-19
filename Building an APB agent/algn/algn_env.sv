class algn_env extends uvm_env;

    `uvm_component_utils(algn_env)

    apb_agent agent_apb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent_apb = apb_agent::type_id::create("agent_apb", this);
    endfunction

endclass
