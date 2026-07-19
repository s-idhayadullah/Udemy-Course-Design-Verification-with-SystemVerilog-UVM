
`uvm_analysis_imp_decl(_item)

class apb_cover_index_wrapper#(int unsigned MAX_VALUE_PLUS_1 = 16) extends uvm_component;

    `uvm_component_param_utils(apb_cover_index_wrapper#(MAX_VALUE_PLUS_1))

    covergroup cover_index with function sample(int unsigned value);
        option.per_instance = 1;

        index: coverpoint value{
            option.comment = "Index";

            bins values[MAX_VALUE_PLUS_1] = {[0:MAX_VALUE_PLUS_1-1]};
        }
    endgroup

    function new(string name = "", uvm_component parent);
        super.new(name, parent);

        cover_index = new();
        cover_index.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_index"));
    endfunction

    virtual function void sample(int unsigned value);
        cover_index.sample(value);
    endfunction

endclass : apb_cover_index_wrapper



class apb_coverage extends uvm_component implements apb_reset_handler;

    `uvm_component_utils(apb_coverage)
    
    apb_agent_config agent_config;

    //port for receiving collected item
    uvm_analysis_imp_item#(apb_item_mon, apb_coverage) port_item;

    apb_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH) wrap_cover_addr_0;

    apb_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH) wrap_cover_addr_1;

    apb_cover_index_wrapper#(`APB_MAX_DATA_WIDTH) wrap_cover_wr_data_0;

    apb_cover_index_wrapper#(`APB_MAX_DATA_WIDTH) wrap_cover_wr_data_1;

    apb_cover_index_wrapper#(`APB_MAX_DATA_WIDTH) wrap_cover_rd_data_0;

    apb_cover_index_wrapper#(`APB_MAX_DATA_WIDTH) wrap_cover_rd_data_1;



    covergroup cover_item with function sample(apb_item_mon item);
        option.per_instance = 1;

        direction: coverpoint item.dir{
            option.comment = "Direction of the APB access";
        }

        response: coverpoint item.response{
            option.comment = "Response of the APB access";
        }

        length: coverpoint item.length{
            option.comment = "Length of the APB access";

            bins length_eq_2     = {2};
            bins length_le_10[8] = {[3:10]};
            bins length_gt_10    = {[11:$]};
        }

        prev_item_delay: coverpoint item.prev_item_delay{
            option.comment = "Delay, in clock cycles, between two consecutive APB accesses";
        
            bins back2back       = {0};
            bins delay_le_5[5]   = {[1:5]};
            bins delay_gt_5      = {[6:$]};
        }

        response_x_direction: cross response, direction;

        trans_direction: coverpoint item.dir{
            option.comment = "Transitions of the APB direction";

            bins direction_trans[] = (APB_READ, APB_WRITE => APB_READ, APB_WRITE);
        }

    endgroup

    covergroup cover_reset with function sample(bit psel);
        option.per_instance = 1;

        access_ongoing: coverpoint psel{
            option.comment = "An access was ongoing at reset";
        }
    endgroup

    function new(string name = "", uvm_component parent);
        super.new(name, parent);

        port_item = new("port_item", this);

        cover_item = new();
        cover_item.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_item"));
        cover_reset = new();
        cover_reset.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_reset"));
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        wrap_cover_addr_0    = apb_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_0", this);
        wrap_cover_addr_1    = apb_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_1", this);
        wrap_cover_wr_data_0 = apb_cover_index_wrapper#(`APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wr_data_0", this);
        wrap_cover_wr_data_1 = apb_cover_index_wrapper#(`APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wr_data_1", this);
        wrap_cover_rd_data_0 = apb_cover_index_wrapper#(`APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rd_data_0", this);
        wrap_cover_rd_data_1 = apb_cover_index_wrapper#(`APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rd_data_1", this);

    endfunction


    virtual function void handle_reset(uvm_phase phase);
        apb_vif vif = agent_config.get_vif();

        cover_reset.sample(vif.psel);
    endfunction

    
    virtual function void write_item(apb_item_mon item);
        cover_item.sample(item);

        for(int i=0; i<`APB_MAX_ADDR_WIDTH; i++) begin
            if(item.addr[i]) begin
                wrap_cover_addr_1.sample(i);
            end
            else begin
                wrap_cover_addr_0.sample(i);
            end
        end

        for(int i=0; i<`APB_MAX_DATA_WIDTH; i++) begin
            case(item.dir)

                APB_WRITE: begin
                    if(item.addr[i]) begin
                        wrap_cover_wr_data_1.sample(i);
                    end
                    else begin
                        wrap_cover_wr_data_0.sample(i);
                    end        
                end

                APB_READ: begin
                    if(item.addr[i]) begin
                        wrap_cover_rd_data_1.sample(i);
                    end
                    else begin
                        wrap_cover_rd_data_0.sample(i);
                    end
                end

                default: begin
                    `uvm_error("ALGORITM_ISSUE", $sformatf("This version of code doesn't support this item.dir: %0s", item.dir.name()))
                end

            endcase
        end

    endfunction

endclass
