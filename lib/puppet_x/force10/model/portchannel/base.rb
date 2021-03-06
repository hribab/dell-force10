require 'puppet_x/force10/model'
require 'puppet_x/force10/model/portchannel'
require 'puppet_x/force10/model/portchannel/generic'
require 'puppet_x/force10/model/interface/base'

module PuppetX::Force10::Model::Portchannel::Base
  extend PuppetX::Force10::Model::Portchannel::Generic

  def self.register(base)
    portchannel_scope = /^(L*\s*(\d+)\s+(.*))/

    register_main_params(base)

    base.register_scoped(:untagged_vlan, portchannel_scope) do
      cmd "show interface port-channel %s" % base.name
      match do |empty_match|
        unless empty_match.nil?
          :false  #This is so we always go through the "add" swimlane
        end
      end
      add do |transport, value|
        vlans = PuppetX::Force10::Model::Interface::Base.vlans_from_list(value)
        PuppetX::Force10::Model::Interface::Base.update_vlans(transport, vlans, false, ["po", base.name])
      end
      remove { |*_| }
    end

    base.register_scoped(:tagged_vlan, portchannel_scope) do
      cmd "show interface port-channel %s" % base.name
      match do |empty_match|
        unless empty_match.nil?
          :false
        end
      end
      add do |transport, value|
        vlans = PuppetX::Force10::Model::Interface::Base.vlans_from_list(value)
        PuppetX::Force10::Model::Interface::Base.update_vlans(transport, vlans, true, ["po", base.name])
      end
      remove { |*_| }
    end
  end
end
