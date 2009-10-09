require 'fileutils'

module Perennial
  # = Perennial::Daemon provides a relatively simple
  # interface to creating unix daemons from a given process.
  # Namely, it focuses on three providing tools for
  # a couple of simple purposes.
  #
  # == Turning a process into a daemon
  #
  # This approach is as as simple as calling
  # Perennial::Daemon.daemonize! - the current process
  # will then be a daemon, the non-daemon processes
  # will be killed and if started by the loader, it will
  # also write a pid out.
  #
  # == Checking whether a process is alive
  #
  # Perennial::Daemon.alive?(pid) is a super simple way
  # to check if a pid (as an integer) is current active / alive,
  # 
  # Perennial::Daemon.any_alive? takes a type and tells you if
  # any processes with the associated type are alive.
  #
  # == Storing / Retrieving Pids for a Given Loader Type
  #
  # Perennial::Daemon.daemonize! will store the pid for
  # the current process if Perennial::Loader.current_type
  # is present.
  #
  # Perennial::Daemon.any_alive?(type = :all) and
  # Perennial::Daemon.kill_all(type = :all) can be
  # used to deal with checking the status of and killing
  # processes associated with a given loader type.
  class Daemon
    include Perennial::Loggable
    
    class << self
      
      def any_alive?(type = :all)
        !pid_file_for(type).empty?
      end
      
      # Returns true / false depending on whether
      # a process with the given pid exists.
      def alive?(pid)
        Process.kill(0, pid)
        return true
      rescue Errno::ESRCH
        return false
      rescue SystemCallError => e
  			return true
      end
      
      # Kills all processes associated with a certain app type.
      # E.g. Given a loader is starting a :client, kill_all(:client)
      # would kill all associated processes (usually after daemonizing)
      # and kill_all would do the same - but if we also started
      # a process for :server, kill_all(:client wouldn't kill the
      # the process where as kill_all would.
      def kill_all(type = :all)
        kill_all_from(pid_file_for(type))
        return false
      end
      
      # Converts the current process into a Unix-daemon using
      # the double fork approach. Also, changes process file
      # mask to 000 and reopens STDIN / OUT to /dev/null
      def daemonize!(should_exit = true)
        if detached_fork { exit if should_exit }
          Process.setsid
          detached_fork { exit }
          reinitialize_stdio
          yield if block_given?
        end
      end
      
      def daemonize_current_type!
        daemonize! do
          write_pid
          Perennial::Settings.verbose = false
        end
      end
      
      # Cleans up processes for the current application type
      # (deteremined by the loader) and then removes the pid file.
      def cleanup!
        f = pids_file_for(Loader.current_type)
        FileUtils.rm_f(f) if (pids_from(f) - Process.pid).blank?
      end
      
      # Returns an array of pid's associated with a given type.
      def pids_for_type(type)
        pids_from(pid_file_for(type))
      end
      
      protected

      def reinitialize_stdio
        File.umask    0000
        STDIN.reopen  "/dev/null"
        STDOUT.reopen "/dev/null", "a"
        STDERR.reopen STDOUT
      end

      def kill_all_from(file)
        pids = pids_from(file)
        pids.each { |p| Process.kill("TERM", p) unless p == Process.pid }
        FileUtils.rm_f(file)
      rescue => e
        Perennial::Logger.log_exception(e)
      end

      def pid_file_for(type)
        type = "*" if type == :all
        Settings.root / "tmp" / "pids" / "#{type.to_s.underscore}.pid"
      end

      def pids_from(files)
        pids = []
        Dir[files].each do |file|
          pids += File.read(file).split("\n").map { |l| l.strip.to_i(10) }
        end
        pids.uniq.select { |p| alive?(p) }
      end

      def write_pid
        type = Loader.current_type
        return if type.blank?
        f = pid_file_for(type)
        pids = pids_from(f)
        pids << Process.pid unless pids.include?(Process.pid)
        FileUtils.mkdir_p(File.dirname(f))
        File.open(f, "w+") { |f| f.puts pids.join("\n") }
      end
      
      def detached_fork
        pid = fork
        unless pid.nil?
          Process.detach(pid)
          yield if block_given?
        end
        pid
      end
      
    end
  end
end