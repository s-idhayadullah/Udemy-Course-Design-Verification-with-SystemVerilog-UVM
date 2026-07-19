class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    algn_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = algn_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

endclass


class reg_access_test extends base_test;

    `uvm_component_utils(reg_access_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "TEST_DONE");
        #(100ns);

        /*
        for(int i=0; i<10; i++) begin
            apb_item_drv item = apb_item_drv::type_id::create("item");

            void'(std::randomize(item));

            `uvm_info("DEBUG", $sformatf("[%0d] item: %0s", i, item.convert2string()), UVM_LOW)
            `uvm_info("DEBUG", "this is the end of the test", UVM_LOW)

        end
        */
        fork
            begin
                apb_vif vif = env.agent_apb.agent_config.get_vif();

                repeat(3) begin
                    @(posedge vif.psel);
                end

                #(11ns);
                vif.preset_n <= 0;

                repeat(4) begin
                    @(posedge vif.pclk);
                end

                vif.preset_n <= 1;
            end

            begin
                apb_simple_sequence simple_seq = apb_simple_sequence::type_id::create("simple_seq");
            
                void'(simple_seq.randomize() with{
                    item.addr == 'h0000;
                    item.dir == APB_WRITE;
                    item.data == 'h11;
                });

                simple_seq.start(env.agent_apb.sequencer);
            end

            begin
                apb_rw_sequence rw_seq = apb_rw_sequence::type_id::create("rw_seq");
            
                void'(rw_seq.randomize() with{
                    addr == 'h000C;
                });

                rw_seq.start(env.agent_apb.sequencer);
            end
        
            begin
                apb_random_sequence random_seq = apb_random_sequence::type_id::create("random_seq");

                void'(random_seq.randomize() with{
                    num_item == 3;
                });

                random_seq.start(env.agent_apb.sequencer);
            end
        join

        begin
            apb_random_sequence random_seq = apb_random_sequence::type_id::create("random_seq");

            void'(random_seq.randomize() with{
                num_item == 3;
            });

            random_seq.start(env.agent_apb.sequencer);
        end

        #(100ns);

        phase.drop_objection(this, "TEST_DONE");

    endtask

endclass
