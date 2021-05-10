# Docker-plotman
Docker container for CHIA plotman by ericaltendorf https://github.com/ericaltendorf/plotman

# Mountpoints
- /root/.config/plotman/
- /chialogs
- /mnt/tmp00
- /mnt/dst


# Config example
```yml
# Default/example plotman.yaml configuration file

# Options for display and rendering
user_interface:
        # Call out to the `stty` program to determine terminal size, instead of
        # relying on what is reported by the curses library.   In some cases,
        # the curses library fails to update on SIGWINCH signals.  If the
        # `plotman interactive` curses interface does not properly adjust when
        # you resize the terminal window, you can try setting this to True. 
        use_stty_size: True

# Where to plot and log.
directories:
        # One directory in which to store all plot job logs (the STDOUT/
        # STDERR of all plot jobs).  In order to monitor progress, plotman
        # reads these logs on a regular basis, so using a fast drive is
        # recommended.
        log: /chialogs

        # One or more directories to use as tmp dirs for plotting.  The
        # scheduler will use all of them and distribute jobs among them.
        # It assumes that IO is independent for each one (i.e., that each
        # one is on a different physical device).
        #
        # If multiple directories share a common prefix, reports will
        # abbreviate and show just the uniquely identifying suffix.
        tmp:
                - /mnt/tmp00

        # Optional: Allows overriding some characteristics of certain tmp
        # directories. This contains a map of tmp directory names to
        # attributes. If a tmp directory and attribute is not listed here,
        # it uses the default attribute setting from the main configuration.
        #
        # Currently support override parameters:
        #     - tmpdir_max_jobs
        tmp_overrides:
                # In this example, /mnt/tmp/00 is larger than the other tmp
                # dirs and it can hold more plots than the default.
                "/mnt/tmp/00":
                        tmpdir_max_jobs: 7

        # Optional: tmp2 directory.  If specified, will be passed to
        # chia plots create as -2.  Only one tmp2 directory is supported.
        # tmp2: /mnt/tmp/a

        # One or more directories; the scheduler will use all of them.
        # These again are presumed to be on independent physical devices,
        # so writes (plot jobs) and reads (archivals) can be scheduled
        # to minimize IO contention.
        dst:
                - /mnt/dst

        # Archival configuration.  Optional; if you do not wish to run the
        # archiving operation, comment this section out.
        #
        # Currently archival depends on an rsync daemon running on the remote
        # host, and that the module is configured to match the local path.
        # See code for details.
        #archive:
        #        rsyncd_module: plots
        #        rsyncd_path: /plots
        #        rsyncd_bwlimit: 80000  # Bandwidth limit in KB/s
        #        rsyncd_host: myfarmer
        #        rsyncd_user: chia
                # Optional index.  If omitted or set to 0, plotman will archive
                # to the first archive dir with free space.  If specified,
                # plotman will skip forward up to 'index' drives (if they exist).
                # This can be useful to reduce io contention on a drive on the
                # archive host if you have multiple plotters (simultaneous io
                # can still happen at the time a drive fills up.)  E.g., if you
                # have four plotters, you could set this to 0, 1, 2, and 3, on
                # the 4 machines, or 0, 1, 0, 1.
                #   index: 0


# Plotting scheduling parameters
scheduling:
        # Run a job on a particular temp dir only if the number of existing jobs
        # before tmpdir_stagger_phase_major tmpdir_stagger_phase_minor
        # is less than tmpdir_stagger_phase_limit.
        # Phase major corresponds to the plot phase, phase minor corresponds to
        # the table or table pair in sequence, phase limit corresponds to
        # the number of plots allowed before [phase major, phase minor]
        tmpdir_stagger_phase_major: 4
        tmpdir_stagger_phase_minor: 2
        # Optional: default is 1
        tmpdir_stagger_phase_limit: 2

        # Don't run more than this many jobs at a time on a single temp dir.
        tmpdir_max_jobs: 7

        # Don't run more than this many jobs at a time in total.
        global_max_jobs: 12

        # Don't run any jobs (across all temp dirs) more often than this, in minutes.
        global_stagger_m: 30

        # How often the daemon wakes to consider starting a new plot job, in seconds.
        polling_time_s: 20


# Plotting parameters.  These are pass-through parameters to chia plots create.
# See documentation at
# https://github.com/Chia-Network/chia-blockchain/wiki/CLI-Commands-Reference#create
plotting:
        k: 32
        e: False             # Use -e plotting option
        n_threads: 2         # Threads per job
        n_buckets: 128       # Number of buckets to split data into
        job_buffer: 4608     # Per job memory
        # If specified, pass through to the -f and -p options.  See CLI reference.
        farmer_pk: ...
        pool_pk: ...
```      

# Find farmer_pk and pool_pk
cd /Applications/Chia.app/Contents/Resources/app.asar.unpacked/daemon
./chia keys show
