module task_lifetime;


    initial begin
        #5ns;
        t1();
        #6ns;
        t2();
        #5ns;
        $finish;
    end

    task printf1;
        fork
            begin
                forever begin
                    $display("%0t 1", $time());
                    #1ns;
                end
            end
            begin
                #3ns;
            end
        join_any;
        disable fork;
    endtask


    task printf2;
        fork
            forever begin
                $display("2");
                #1ns;
            end
        join_none;
    endtask

    task t1;
        fork
            printf1();
        join_none;
    endtask

    task t2;
        fork
            printf1();
        join_none;
    endtask

endmodule