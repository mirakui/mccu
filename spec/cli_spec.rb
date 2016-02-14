require 'spec_helper'
require 'mccu/cli'
require 'mccu/client'

describe Mccu::Cli do
  let(:cli) { Mccu::Cli }
  subject { cli.start opts }
  before(:all) do
    c = Mccu::Client.new 'localhost'
    c.purge_matched //
    c.set 'apple', 'red'
    c.set 'banana', 'yellow'
    c.set 'grape', 'purple'
  end

  describe 'list' do
    let(:opts) { %w[list] }

    it { expect { subject }.to output(/grape/).to_stdout }

    describe '--prefix' do
      let(:opts) { %w[list --prefix=ba] }
      it { expect { subject }.to output(/banana/).to_stdout }
    end

    describe '--regex' do
      let(:opts) { %w[list --regex=.*ape$] }
      it { expect { subject }.to output(/grape/).to_stdout }
    end
  end
end
