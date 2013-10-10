require 'spec_helper'

describe PasswordIsStrongValidator do

  subject(:password_validator) do
    described_class.new(
        :attributes => attributes
    )
  end

  let(:attribute) do
    :params
  end

  let(:attributes) do
    attribute
  end


  context '#contains_repetition?' do

    it 'should return true for aaaa' do
      password_validator.send(:contains_repetition?, 'aaaa').should be_true
    end

    it 'should return true for ababab' do
      password_validator.send(:contains_repetition?, 'ababab').should be_true
    end

    it 'should return true for abcabcabc' do
      password_validator.send(:contains_repetition?, 'abcabcabc').should be_true
    end

    it 'should return true for abcdabcd' do
      password_validator.send(:contains_repetition?, 'abcdabcd').should be_true
    end

    it 'should return false for abcd1234abcd' do
      password_validator.send(:contains_repetition?, 'abcd1234abcd').should be_false
    end

  end



  context '#mutate_pass' do

    variants = [
      "metasp1oit",
      "me7asploi7",
      "me7asp1oi7",
      "meta$ploit",
      "meta$p1oit",
      "me7a$ploi7",
      "me7a$p1oi7",
      "m3tasploit",
      "m3tasp1oit",
      "m37asploi7",
      "m37asp1oi7",
      "m3ta$ploit",
      "m3ta$p1oit",
      "m37a$ploi7",
      "m37a$p1oi7",
      "metaspl0it",
      "metasp10it",
      "me7aspl0i7",
      "me7asp10i7",
      "meta$pl0it",
      "meta$p10it",
      "me7a$pl0i7",
      "me7a$p10i7",
      "m3taspl0it",
      "m3tasp10it",
      "m37aspl0i7",
      "m37asp10i7",
      "m3ta$pl0it",
      "m3ta$p10it",
      "m37a$pl0i7",
      "m37a$p10i7",
      "met@sploit",
      "met@sp1oit",
      "me7@sploi7",
      "me7@sp1oi7",
      "met@$ploit",
      "met@$p1oit",
      "me7@$ploi7",
      "me7@$p1oi7",
      "m3t@sploit",
      "m3t@sp1oit",
      "m37@sploi7",
      "m37@sp1oi7",
      "m3t@$ploit",
      "m3t@$p1oit",
      "m37@$ploi7",
      "m37@$p1oi7",
      "met@spl0it",
      "met@sp10it",
      "me7@spl0i7",
      "me7@sp10i7",
      "met@$pl0it",
      "met@$p10it",
      "me7@$pl0i7",
      "me7@$p10i7",
      "m3t@spl0it",
      "m3t@sp10it",
      "m37@spl0i7",
      "m37@sp10i7",
      "m3t@$pl0it",
      "m3t@$p10it",
      "m37@$pl0i7",
      "m37@$p10i7"
      ]

    it 'should return all the expected mutations of a password' do
      password_validator.send(:mutate_pass, 'metasploit').should == variants
    end

  end


  context '#is_common_password?' do

    PasswordIsStrongValidator::COMMON_PASSWORDS.each do |password|

      it "should return true for #{password}"  do
        password_validator.send(:is_common_password?, password).should be_true
      end

      it "should return true for #{password}!"  do
        password_validator.send(:is_common_password?, "#{password}!").should be_true
      end

      it "should return true for #{password}1"  do
        password_validator.send(:is_common_password?, "#{password}1").should be_true
      end

      it "should return true for #{password}9"  do
        password_validator.send(:is_common_password?, "#{password}1").should be_true
      end

      it "should return true for #{password}99"  do
        password_validator.send(:is_common_password?, "#{password}12").should be_true
      end

      it "should return true for #{password}123"  do
        password_validator.send(:is_common_password?, "#{password}123").should be_true
      end

      it "should return true for #{password}123!" do
        password_validator.send(:is_common_password?, "#{password}123!").should be_true
      end

    end

    it "should return true for r00t" do
      password_validator.send(:is_common_password?, "r00t").should be_true
    end

    it "should return true for m3t@spl0it" do
      password_validator.send(:is_common_password?, "m3t@spl0it").should be_true
    end

    it "should return true for m3t@spl0it123!" do
      password_validator.send(:is_common_password?, "m3t@spl0it123!").should be_true
    end
  end

  context '#contains_username' do

    it 'should return true if username and password are the same' do
      password_validator.send(:contains_username?, 'admin', 'admin').should be_true
    end

    it 'should return true if the password contains the username as part of it' do
      password_validator.send(:contains_username?, 'admin', '123admin123').should be_true
    end

    it 'should return false otherwise' do
      password_validator.send(:contains_username?, 'admin', 'foobar').should be_false
    end
  end

  context '#is_simple?' do

    it "should return true if no number" do
      password_validator.send(:is_simple?, "b@carat").should be_true
    end

    it "should return true if no special char" do
      password_validator.send(:is_simple?, "bacarat4").should be_true
    end

    it "should return true if no letters" do
      password_validator.send(:is_simple?, "1337").should be_true
    end

    PasswordIsStrongValidator::SPECIAL_CHARS.each_char do |char|

      it "should return false with a #{char}" do
        password_validator.send(:is_simple?, "bacarat4#{char}").should be_false
      end
    end
  end

  context '#validate_each' do

    subject(:errors) do
      record.errors[attribute]
    end

    def validate_each
      password_validator.validate_each(record, attribute, value)
    end

    let(:record) do
      Object.new.tap { |object|
        object.extend ActiveModel::Validations
        object.class.module_eval { attr_accessor :username }
        object.username = 'admin'
      }
    end


    context 'with a password with no special char' do
      let(:value) { "bacarat4" }

      it 'should record an error' do
        validate_each
        errors.should_not be_empty
      end

      it 'should have an error of "must contain letters, numbers, and at least one special character"' do
        validate_each
        errors.include?("must contain letters, numbers, and at least one special character").should be_true
      end
    end

    context 'with a password with no numbers' do
      let(:value) { "b@carat" }

      it 'should record an error' do
        validate_each
        errors.should_not be_empty
      end

      it 'should have an error of "must contain letters, numbers, and at least one special character"' do
        validate_each
        errors.include?("must contain letters, numbers, and at least one special character").should be_true
      end
    end

    context 'with a password with no letters' do
      let(:value) { "1337@" }

      it 'should record an error' do
        validate_each
        errors.should_not be_empty
      end

      it 'should have an error of "must contain letters, numbers, and at least one special character"' do
        validate_each
        errors.include?("must contain letters, numbers, and at least one special character").should be_true
      end
    end

    context 'with a password containing the username' do
      let(:value) { "admin1" }

      it 'should record an error' do
        validate_each
        errors.should_not be_empty
      end

      it 'should have an error of "must not contain the username"' do
        validate_each
        errors.include?("must not contain the username").should be_true
      end
    end

    context 'with a common password' do
      let(:value) { "password" }

      it 'should record an error' do
        validate_each
        errors.should_not be_empty
      end

      it 'should have an error of "must not be a common password"' do
        validate_each
        errors.include?("must not be a common password").should be_true
      end
    end

    context 'with a mutated common password' do
      let(:value) { "P@ssw0rd1!" }

      it 'should record an error' do
        validate_each
        errors.should_not be_empty
      end

      it 'should have an error of "must not be a common password"' do
        validate_each
        errors.include?("must not be a common password").should be_true
      end
    end

    context 'with a repeated pattern' do
      let(:value) { "abcdabcd" }

      it 'should record an error' do
        validate_each
        errors.should_not be_empty
      end

      it 'should have an error of "must not be a predictable sequence of characters"' do
        validate_each
        errors.include?("must not be a predictable sequence of characters").should be_true
      end
    end

  end

end