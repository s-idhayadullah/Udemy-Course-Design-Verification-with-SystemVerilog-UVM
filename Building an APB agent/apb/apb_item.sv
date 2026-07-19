class apb_item_base extends uvm_sequence_item;

    `uvm_object_utils(apb_item_base)

    rand apb_dir dir;
    rand apb_addr addr;
    rand apb_data data;

    function new(string name = "");
        super.new(name);
    endfunction

    virtual function string convert2string();
        string result = $sformatf("dir: %0s, addr: %0x", dir.name(), addr);

        return result;
    endfunction


endclass


class apb_item_drv extends apb_item_base;

    `uvm_object_utils(apb_item_drv)

    rand int unsigned pre_drive_delay;
    rand int unsigned post_drive_delay;

    constraint pre_drive_delay_default{
        soft pre_drive_delay <= 5;
    }

    constraint post_drive_delay_default{
        soft post_drive_delay <= 5;
    }


    function new(string name = "");
        super.new(name);
    endfunction

    virtual function string convert2string();
        string result = super.convert2string();

        if(dir == APB_WRITE) begin
            result = $sformatf("%s, data: %0x", result, data);
        end
        
        result = $sformatf("%s, pre_drive_delay: %0d, post_drive_delay: %0d", result, pre_drive_delay, post_drive_delay);

        return result;
    endfunction

endclass



class apb_item_mon extends apb_item_base;

    `uvm_object_utils(apb_item_mon)

    apb_response response;
    int unsigned length;
    int unsigned prev_item_delay;

    function new(string name = "");
        super.new(name);
    endfunction

    virtual function string convert2string();
        string result = super.convert2string();

        result = $sformatf("%s, data: %0x, response: %s, length: %0d, prev_item_delay: %0d", result, data, response.name(), length, prev_item_delay);

        return result;
    endfunction

endclass
