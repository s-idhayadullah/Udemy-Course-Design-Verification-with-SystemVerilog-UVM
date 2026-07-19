typedef virtual apb_if apb_vif;

typedef enum bit {APB_READ = 0, APB_WRITE = 1} apb_dir;

typedef bit[`APB_MAX_ADDR_WIDTH-1:0] apb_addr;

typedef bit[`APB_MAX_DATA_WIDTH-1:0] apb_data;

typedef enum bit {APB_OKAY = 0, APB_ERR = 1} apb_response;
