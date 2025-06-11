module task_lifetime;

    event atlas;
    // initial begin
    //     #5ns;
    //     t1();
    //     #6ns;
    //     t2();
    //     #5ns;
    //     $finish;
    // end

    initial begin
        #5ns;
        eventf1();
        t1();
        #5ns;
        $finish;
    end

    initial begin
        #11ns;
        -> atlas;
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
                $display("%0t 2", $time());
                #1ns;
            end
        join_none;
    endtask

    task eventf1;
        fork
            begin
                @(atlas);
                $display("HALO");
            end
        join_none;
    endtask

    task t1;
        fork
            printf2();
        join_none;
    endtask

    task t2;
        fork
            printf2();
        join_none;
    endtask

endmodule