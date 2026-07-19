class apb_base_sequence extends uvm_sequence#(.REQ(apb_item_drv));
    
    `uvm_declare_p_sequencer(apb_sequencer)

    `uvm_object_utils(apb_base_sequence)

    function new(string name = "");
        super.new(name);
    endfunction

endclass



class apb_simple_sequence extends apb_base_sequence;

    `uvm_object_utils(apb_simple_sequence)

    rand apb_item_drv item;

    function new(string name = "");
        super.new(name);

        item = apb_item_drv::type_id::create("item");
    endfunction

    virtual task body();
        start_item(item);            //  |
                                     //  | -->  equivalent to `uvm_send(item)
        finish_item(item);           //  |

        //`uvm_do(item);            This creates, randomizes and sends items itself

    endtask

endclass



class apb_rw_sequence extends apb_base_sequence;

    `uvm_object_utils(apb_rw_sequence)

    rand apb_addr addr;
    rand apb_data wr_data;

    function new(string name = "");
        super.new(name);
    endfunction

    virtual task body();

        /*
        apb_item_drv item = apb_item_drv::type_id::create("item");

        void'(item.randomize() with{
            dir == APB_READ;
            addr == local::addr;
        });

        start_item(item);
        finish_item(item);

        void'(item.randomize() with{
            dir == APB_WRITE;
            addr == local::addr;
            data == wr_data;
        });

        start_item(item);
        finish_item(item);
        */

        apb_item_drv item;
        //apb_item_drv item = apb_item_drv::type_id::create("item");   -->  causes no problem here, but no use

        `uvm_do_with(item, {
            dir == APB_READ;
            addr == local::addr;
        })

        `uvm_do_with(item, {
            dir == APB_WRITE;
            addr == local::addr;
            data == wr_data;
        })

    endtask

endclass



class apb_random_sequence extends apb_base_sequence;

    `uvm_object_utils(apb_random_sequence)

    rand int unsigned num_item;

    constraint num_item_default{
        soft num_item inside {[1:10]};
    }

    function new(string name = "");
        super.new(name);
    endfunction

    virtual task body();
        for(int i=0; i<num_item; i++) begin
            /*
            apb_simple_sequence simp_seq = apb_simple_sequence::type_id::create("simp_seq");
            void'(simp_seq.randomize());
            simp_seq.start(m_sequencer, this);
            */
            apb_simple_sequence simp_seq;

            `uvm_do(simp_seq);
        end
    endtask

endclass




