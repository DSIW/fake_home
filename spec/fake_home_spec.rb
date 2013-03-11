require "spec_helper"

describe Home do
  let!(:old_home) { ENV["HOME"] }
  let(:explicit_path) { "/tmp/fake_home" }
  let(:tmp_path) { %r{/tmp/test_.+_home} }

  subject { Home.new(*args) }
  let(:args) { nil }

  describe "#init" do
    context "with set prefix and default suffix" do
      let(:args) { [{prefix: "new_prefix"}] }

      its(:prefix) { should == "new_prefix" }
      its(:suffix) { should == "home" }
    end

    context "with default prefix and set suffix" do
      let(:args) { [{suffix: "new_suffix"}] }

      its(:prefix) { should == "test" }
      its(:suffix) { should == "new_suffix" }
    end

    context "with explicit home path" do
      let(:args) { explicit_path }

      its(:fake_home) { should == explicit_path}
    end

    context "with explicit path and prefix" do
      let(:args) { [explicit_path, prefix: "new_prefix"] }
      its(:fake_home) { should == explicit_path}
      its(:prefix) { should == "new_prefix" }
    end
  end

  describe "#original_home" do
    its(:original_home) { should be_nil }

    context "after prepare" do
      before { subject.prepare }
      it "should be the old $HOME" do
        subject.original_home.should == old_home
      end
    end
  end

  describe "#prepare" do
    let(:args) { explicit_path }
    before { subject.prepare }
    it "should set new home in ENV" do
      ENV["HOME"].should == explicit_path
    end
  end

  describe "#prepared?" do
    it "should not be prepared" do
      subject.should_not be_prepared
    end

    context "after prepare" do
      before { subject.prepare }
      it "should be prepared" do
        subject.should be_prepared
      end
    end
  end

  describe "#restore" do
    it "should raise error if not prepared" do
      expect{ subject.restore }.to raise_error PreparationError
    end

    context "when prepared and restored" do
      before :each do
        subject.prepare
        subject.restore
      end

      it "should restore old home path in ENV" do
        ENV["HOME"].should == old_home
      end

      it "should remove recursive fake_home directory" do
        File.exist?(subject.fake_home).should be_false
        subject.fake_home.should =~ tmp_path
      end
    end
  end

  describe "#restored?" do
    it "should be restored" do
      subject.should_not be_restored
    end

    context "after prepare" do
      before { subject.prepare }
      it "should not be restored" do
        subject.should_not be_restored
      end

      context "after restore" do
        before { subject.restore }
        it "should be restored" do
          subject.should be_restored
        end
      end
    end
  end

  describe "#fake_home" do
    let(:args) { explicit_path }

    its(:fake_home) { should == explicit_path }

    context "when block is given then" do
      it "should not be prepared before fake_home call" do
        subject.should_not be_prepared
      end
      it "should yield fake_home directory" do
        expect { |b| subject.fake_home(&b) }.to yield_with_args(explicit_path)
      end
      it "should be restored after fake_home" do
        subject.fake_home { |fake_home| }
        subject.should be_restored
      end
    end
  end

  describe "Private methods" do
    describe "#mkdir" do
      its(:mkdir) { should =~ tmp_path }
      it "should create the directory in filesystem" do
        File.exist?(subject.send(:mkdir)).should be_true
      end

      context "when explicit path is set then" do
        let(:args) { explicit_path }
        before { subject.send(:mkdir) }
        its(:mkdir) { should == explicit_path }
        it "should create the directory in filesystem" do
          File.exist?(subject.send(:mkdir)).should be_true
        end
      end
    end
  end
end
