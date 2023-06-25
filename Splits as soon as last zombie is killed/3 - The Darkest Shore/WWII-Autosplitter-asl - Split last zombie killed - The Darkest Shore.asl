state("s2_mp64_ship")
{
    int round_counter : 0xA768DFC;
    byte is_paused : 0x281F400; 
    string13 map_name : 0xC802B9C;
    int round_is_completed : 0x27330D4;
    int loading_screen : 0x270EAC4;
    int beach : 0xA4B4ED4;
}

startup
{
    vars.timer_start = 0;
    vars.split_index = 1;
    vars.split_triggered = false;
    vars.prev_round_completed = 0;
    vars.beach_split_triggered = false; // new variable for beach split condition
}

start
{
    if (current.round_counter == 0)
    {
        vars.timer_start = 0;
        vars.split_index = 0;
        vars.split_triggered = false;
        vars.prev_round_completed = 0;
        vars.beach_split_triggered = false; // reset beach split condition
    }
    if (current.round_counter == 0 && vars.timer_start == 0 && current.loading_screen > 0)
    {
        System.Threading.Thread.Sleep(200);
        vars.timer_start = 1;
        return true;
    }
}

reset
{
    if (current.map_name.Equals("mp_hub_zombies_0") || (current.round_counter == 0 && old.round_counter != 0))
    {
        vars.timer_start = 0;
        vars.split_triggered = false; // reset flag
        vars.prev_round_completed = 0;
        vars.beach_split_triggered = false; // reset beach split condition
        return true;
    }
    return false;
}

isLoading
{
    if (current.is_paused == 1) return true;
    return false;
}

split
{
    if (current.round_is_completed > vars.prev_round_completed)
    {
        if (!vars.split_triggered)
        {
            if (current.round_is_completed - vars.prev_round_completed >= 1) // Check if at least one round has passed since the last split
            {
                vars.split_triggered = true;
                vars.timer_start = 1; // resume timer
                vars.prev_round_completed = current.round_is_completed;
                return true;
            }
        }
    }
    else
    {
        vars.split_triggered = false; // reset flag if round counter hasn't been triggered yet
    }

    // New condition for beach split
    if (!vars.beach_split_triggered && current.beach == 1)
    {
        vars.beach_split_triggered = true;
        vars.timer_start = 1; // resume timer
        return true;
    }

    return false;
}