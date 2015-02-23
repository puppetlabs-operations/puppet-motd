require 'spec_helper'

shared_examples_for "all motd cases" do
  it {
    should compile.with_all_deps
    should contain_concat('/etc/motd')
    should contain_file('/etc/motd')
    should contain_class('Motd')
    should contain_file('/etc/banner')
    should contain_file('/fake_concat_basedir/_etc_motd/fragments/02_motd_header').with_content(/fact3/)
  }
end

PuppetSpecFacts.facts_for_platform_by_name(["Debian_wheezy_7.7_amd64_3.7.2_structured", "Ubuntu_precise_12.04_amd64_PE-3.3.2_stringified", "Ubuntu_trusty_14.04_amd64_PE-3.3.2_stringified", "CentOS_5.11_x86_64_PE-3.3.2_stringified"]).each do |name, facthash|
  describe "motd", :type => :class do
    let(:facts) { facthash }
    facthash['is_pe'] = (facthash['puppetversion'].include?('Enterprise')) ? true : false

    context "running on #{name}" do
      context "ascii_art enabled" do
        ['graffiti','whimsy','usaflag'].each do |font|
          context "ascii_art_font => #{font}" do
            let(:params) {{
              :enable_ascii_art => 'true',
              :ascii_art_text   => 'Hello, rspec',
              :ascii_art_font   => font,
              :fact_list        => ['fact1', 'fact2', 'fact3'],
            }}


            it_behaves_like "all motd cases"
              gem_provider = facthash['is_pe'] ? 'pe_gem' : "gem"
              it { should contain_package('artii').with(
                'provider' => gem_provider,
              ) }
          end
        end
      end

      context "ascii_art disabled" do
        let(:params) {{
          :enable_ascii_art => 'false',
          :fact_list        => ['fact1','fact2','fact3'],
        }}

        it_behaves_like "all motd cases"
        it { should_not contain_package('artii') }
      end
    end
  end
end
