# Copyright (c) 2007-2008 Li Xiao <iam@li-xiao.com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module DTR

  module Agent
    class Herald
      class WorkingEnvError < StandardError
      end

      include Service::WorkingEnv
      include Service::Agent

      def initialize(working_env_key, agent_env_setup_cmd, runners)
        @working_env_key = working_env_key
        @agent_env_setup_cmd = agent_env_setup_cmd
        @runners = runners
        @env_store = EnvStore.new
        start_service
        start_off
      ensure
        stop_service
      end

      def start_off
        DTR.info "=> Herald starts off..."
        provide_agent_info(@agent_env_setup_cmd, @runners)

        @env_store[@working_env_key] = fetch_working_env
      rescue
        @env_store[@working_env_key] = $!.message
        DTR.error $!.message
      end

      def fetch_working_env
        working_env = lookup_working_env
        DTR.info "=> Got working environment created at #{working_env[:created_at]} by #{working_env[:host]}"

        raise WorkingEnvError.new("No test files need to load?(working env: #{working_env})") if working_env[:files].blank?
        raise WorkingEnvError.new('Setup working environment failed, no runner started.') unless working_env.setup_env(@agent_env_setup_cmd)
        working_env
      end
    end
  end
end
