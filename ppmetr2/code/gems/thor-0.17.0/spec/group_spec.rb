#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Thor::Group do
  describe "task" do
    it "allows to use private methods from parent class as tasks" do
      expect(ChildGroup.start).to eq(["bar", "foo", "baz"])
      expect(ChildGroup.new.baz("bar")).to eq("bar")
    end
  end

  describe "#start" do
    it "invokes all the tasks under the Thor group" do
      expect(MyCounter.start(["1", "2", "--third", "3"])).to eq([ 1, 2, 3 ])
    end

    it "uses argument default value" do
      expect(MyCounter.start(["1", "--third", "3"])).to eq([ 1, 2, 3 ])
    end

    it "invokes all the tasks in the Thor group and his parents" do
      expect(BrokenCounter.start(["1", "2", "--third", "3"])).to eq([ nil, 2, 3, false, 5 ])
    end

    it "raises an error if a required argument is added after a non-required" do
      expect {
        MyCounter.argument(:foo, :type => :string)
      }.to raise_error(ArgumentError, 'You cannot have "foo" as required argument after the non-required argument "second".')
    end

    it "raises when an exception happens within the task call" do
      expect{ BrokenCounter.start(["1", "2", "--fail"]) }.to raise_error
    end

    it "raises an error when a Thor group task expects arguments" do
      expect{ WhinyGenerator.start }.to raise_error(ArgumentError, /thor wrong_arity takes 1 argument, but it should not/)
    end

    it "invokes help message if any of the shortcuts is given" do
      MyCounter.should_receive(:help)
      MyCounter.start(["-h"])
    end
  end

  describe "#desc" do
    it "sets the description for a given class" do
      expect(MyCounter.desc).to eq("Description:\n  This generator runs three tasks: one, two and three.\n")
    end

    it "can be inherited" do
      expect(BrokenCounter.desc).to eq("Description:\n  This generator runs three tasks: one, two and three.\n")
    end

    it "can be nil" do
      expect(WhinyGenerator.desc).to be_nil
    end
  end

  describe "#help" do
    before do
      @content = capture(:stdout) { MyCounter.help(Thor::Base.shell.new) }
    end

    it "provides usage information" do
      expect(@content).to match(/my_counter N \[N\]/)
    end

    it "shows description" do
      expect(@content).to match(/Description:/)
      expect(@content).to match(/This generator runs three tasks: one, two and three./)
    end

    it "shows options information" do
      expect(@content).to match(/Options/)
      expect(@content).to match(/\[\-\-third=THREE\]/)
    end
  end

  describe "#invoke" do
    before do
      @content = capture(:stdout) { E.start }
    end

    it "allows to invoke a class from the class binding" do
      expect(@content).to match(/1\n2\n3\n4\n5\n/)
    end

    it "shows invocation information to the user" do
      expect(@content).to match(/invoke  Defined/)
    end

    it "uses padding on status generated by the invoked class" do
      expect(@content).to match(/finished    counting/)
    end

    it "allows invocation to be configured with blocks" do
      capture(:stdout) do
        expect(F.start).to eq(["Valim, Jose"])
      end
    end

    it "shows invoked options on help" do
      content = capture(:stdout) { E.help(Thor::Base.shell.new) }
      expect(content).to match(/Defined options:/)
      expect(content).to match(/\[--unused\]/)
      expect(content).to match(/# This option has no use/)
    end
  end

  describe "#invoke_from_option" do
    describe "with default type" do
      before do
        @content = capture(:stdout) { G.start }
      end

      it "allows to invoke a class from the class binding by a default option" do
        expect(@content).to match(/1\n2\n3\n4\n5\n/)
      end

      it "does not invoke if the option is nil" do
        expect(capture(:stdout) { G.start(["--skip-invoked"]) }).not_to match(/invoke/)
      end

      it "prints a message if invocation cannot be found" do
        content = capture(:stdout) { G.start(["--invoked", "unknown"]) }
        expect(content).to match(/error  unknown \[not found\]/)
      end

      it "allows to invoke a class from the class binding by the given option" do
        content = capture(:stdout) { G.start(["--invoked", "e"]) }
        expect(content).to match(/invoke  e/)
      end

      it "shows invocation information to the user" do
        expect(@content).to match(/invoke  defined/)
      end

      it "uses padding on status generated by the invoked class" do
        expect(@content).to match(/finished    counting/)
      end

      it "shows invoked options on help" do
        content = capture(:stdout) { G.help(Thor::Base.shell.new) }
        expect(content).to match(/defined options:/)
        expect(content).to match(/\[--unused\]/)
        expect(content).to match(/# This option has no use/)
      end
    end

    describe "with boolean type" do
      before do
        @content = capture(:stdout) { H.start }
      end

      it "allows to invoke a class from the class binding by a default option" do
        expect(@content).to match(/1\n2\n3\n4\n5\n/)
      end

      it "does not invoke if the option is false" do
        expect(capture(:stdout) { H.start(["--no-defined"]) }).not_to match(/invoke/)
      end

      it "shows invocation information to the user" do
        expect(@content).to match(/invoke  defined/)
      end

      it "uses padding on status generated by the invoked class" do
        expect(@content).to match(/finished    counting/)
      end

      it "shows invoked options on help" do
        content = capture(:stdout) { H.help(Thor::Base.shell.new) }
        expect(content).to match(/defined options:/)
        expect(content).to match(/\[--unused\]/)
        expect(content).to match(/# This option has no use/)
      end
    end
  end

  describe "edge-cases" do
    it "can handle boolean options followed by arguments" do
      klass = Class.new(Thor::Group) do
        desc "say hi to name"
        argument :name, :type => :string
        class_option :loud, :type => :boolean

        def hi
          name.upcase! if options[:loud]
          "Hi #{name}"
        end
      end

      expect(klass.start(["jose"])).to eq(["Hi jose"])
      expect(klass.start(["jose", "--loud"])).to eq(["Hi JOSE"])
      expect(klass.start(["--loud", "jose"])).to eq(["Hi JOSE"])
    end

    it "provides extra args as `args`" do
      klass = Class.new(Thor::Group) do
        desc "say hi to name"
        argument :name, :type => :string
        class_option :loud, :type => :boolean

        def hi
          name.upcase! if options[:loud]
          out = "Hi #{name}"
          out << ": " << args.join(", ") unless args.empty?
          out
        end
      end

      expect(klass.start(["jose"])).to eq(["Hi jose"])
      expect(klass.start(["jose", "--loud"])).to eq(["Hi JOSE"])
      expect(klass.start(["--loud", "jose"])).to eq(["Hi JOSE"])
    end
  end
end