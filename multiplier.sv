localparam DATA_WIDTH = 64;

module multiplier (
    input logic                     clk_i,
    input logic                     rsn_i,

    input logic [DATA_WIDTH-1:0]    op_a_i,
    input logic [DATA_WIDTH-1:0]    op_b_i,
    input logic                     enable_i,

    output logic                    ready_o,
    output logic [DATA_WIDTH-1:0]   result_o
);

typedef enum logic [0] {IDLE, WORK} mult_states;

mult_states state, next_state;
logic [DATA_WIDTH-1]                    aux_a;
logic [DATA_WIDTH-1]                    aux_b;
logic [DATA_WIDTH-1:0][DATA_WIDTH*2-1]  aux_results;

always_ff @(posedge clk) begin
    if (!rsn_i) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
    if (!rsn_i) begin
        next_state = IDLE;
        ready_o = {default : 'b0};
        result_o = {default : 'b0};
        aux_result_o = {default : 'b0};
    end
    else begin
        case (state)
        IDLE: begin
            ready_o = {default : 'b0};
            result_o = {default : 'b0};
            aux_result_o = {default : 'b0};
            if (enable_i) begin
                aux_a = op_a_i;
                aux_b = op_b_i;
                for (int i = 0; i < DATA_WIDTH; ++i) begin
                    if (op_b_i[i]) begin
                        aux_results[i] = op_a_i << i;
                    end
                end
                next_state = WORKING;
            end
        end
        WORKING: begin
            for (int ii = 1; ii <= $clog(DATA_WIDTH); ++ii) begin
                for (int i = 0; i < DATA_WIDTH/2*ii; ++i) begin
                    aux_results[i] = aux_results[i*2*ii] + aux_results[i*2*ii+1];
                end
            end
            ready_o = 1'b1;
            result_o = aux_results[0][DATA_WIDTH-1:0];
            next_state = IDLE;
        end
        endcase
    end
end

endmodule
