# encoding: utf-8
require File.dirname(__FILE__) + '/../../spec_helper'

module SendGrid4r::REST::Whitelabel
  describe Links do
    describe 'integration test', :it do
      before do
        Dotenv.load
        @client = SendGrid4r::Client.new(api_key: ENV['SILVER_API_KEY'])
        @subdomain_name = ENV['SUBDOMAIN_LINK']
        @domain_name = ENV['DOMAIN']
        @username = ENV['USERNAME']
        @subuser = ENV['SUBUSER']
        @email1 = ENV['MAIL']
        @password1 = ENV['PASS']
        @ip = @client.get_ips[0].ip
        # celan up test env
        @id1 = nil
        @id2 = nil
        links = @client.get_wl_links
        links.each do |link|
          if link.subdomain == "#{@subdomain_name}1" &&
             link.domain == @domain_name
            @id1 = link.id
          end
          if link.subdomain == "#{@subdomain_name}2" &&
             link.domain == @domain_name
            @id2 = link.id
          end
        end
        # post link
        @link1 = @client.post_wl_link(
          subdomain: @subdomain_name + '1', domain: @domain_name, default: false
        ) if @id1.nil?
        @link2 = @client.post_wl_link(
          subdomain: @subdomain_name + '2', domain: @domain_name, default: false
        ) if @id2.nil?
        # make a default
        @id1 = @link1.id if @id1.nil?
        @id2 = @link2.id if @id2.nil?
        @client.patch_wl_link(id: @id1, default: true)
        @client.delete_wl_link(id: @id2)
        @link2 = @client.post_wl_link(
          subdomain: @subdomain_name + '2', domain: @domain_name, default: false
        )
        # create a subuser
        subusers = @client.get_subusers
        count = subusers.count { |subuser| subuser.username == @subuser }
        @client.delete_subuser(username: @subuser) if count == 1
        @client.post_subuser(
          username: @subuser,
          email: @email1,
          password: @password1,
          ips: [@ip]
        )
      end

      context 'without block call' do
        it '#get_wl_links' do
          links = @client.get_wl_links(
            limit: 100, offset: 0,
            exclude_subusers: true, username: 'somebody', domain: 'example.com'
          )
          expect(links).to be_a(Array)
          links.each do |link|
            expect(link).to be_a(Links::Link)
          end
        end

        it '#post_wl_link' do
          expect(@link2).to be_a(Links::Link)
          expect(@link2.domain).to eq(@domain_name)
          expect(@link2.subdomain).to eq(@subdomain_name + '2')
          expect(@link2.username).to eq(@username)
          expect(@link2.user_id).to be_a(Numeric)
          expect(@link2.default).to eq(false)
          expect(@link2.valid).to eq(false)
          expect(@link2.legacy).to eq(false)
          expect(@link2.dns.domain_cname).to be_a(Links::Record)
          expect(@link2.dns.owner_cname).to be_a(Links::Record)
        end

        it '#get_wl_link' do
          link2 = @client.get_wl_link(id: @link2.id)
          expect(link2).to be_a(Links::Link)
          expect(link2.domain).to eq(@domain_name)
          expect(link2.subdomain).to eq(@subdomain_name + '2')
          expect(link2.username).to eq(@username)
          expect(link2.user_id).to be_a(Numeric)
          expect(link2.default).to eq(false)
          expect(link2.valid).to eq(false)
          expect(link2.legacy).to eq(false)
          expect(link2.dns.domain_cname).to be_a(Links::Record)
          expect(link2.dns.owner_cname).to be_a(Links::Record)
        end

        it '#patch_wl_link' do
          link2 = @client.patch_wl_link(id: @link2.id, default: true)
          expect(link2).to be_a(Links::Link)
          expect(link2.domain).to eq(@domain_name)
          expect(link2.subdomain).to eq(@subdomain_name + '2')
          expect(link2.username).to eq(@username)
          expect(link2.user_id).to be_a(Numeric)
          expect(link2.default).to eq(true)
          expect(link2.valid).to eq(false)
          expect(link2.legacy).to eq(false)
          expect(link2.dns.domain_cname).to be_a(Links::Record)
          expect(link2.dns.owner_cname).to be_a(Links::Record)
        end

        it '#delete_wl_link' do
          @client.delete_wl_link(id: @link2.id)
        end

        it '#get_default_wl_link' do
          link = @client.get_default_wl_link
          expect(link).to be_a(Links::Link)
        end

        it '#validate_wl_link' do
          result1 = @client.validate_wl_link(id: @id1)
          expect(result1).to be_a(Links::Result)
          expect(result1.valid).to be(false)
          expect(result1.validation_results.domain_cname.valid).to be(false)
          expect(result1.validation_results.owner_cname.valid).to be(false)
        end

        it '#get_associated_wl_link' do
          link1 = @client.get_associated_wl_link(username: @subuser)
          expect(link1).to be_a(Links::Link)
        end

        it '#associate_wl_link' do
          @client.associate_wl_link(id: @id1, username: @subuser)
        end

        it '#disassociate_wl_link' do
          @client.associate_wl_link(id: @id1, username: @subuser)
          @client.disassociate_wl_link(username: @subuser)
        end
      end
    end

    describe 'unit test', :ut do
      let(:client) do
        SendGrid4r::Client.new(api_key: '')
      end

      let(:links) do
        '[]'
      end

      let(:link) do
        '{'\
          '"id": 1,'\
          '"domain": "example.com",'\
          '"subdomain": "mail",'\
          '"username": "john@example.com",'\
          '"user_id": 7,'\
          '"default": false,'\
          '"valid": true,'\
          '"legacy": false,'\
          '"dns": {'\
            '"domain_cname": {'\
              '"valid": true,'\
              '"type": "cname",'\
              '"host": "mail.example.com",'\
              '"data": "sendgrid.net"'\
            '},'\
            '"owner_cname": {'\
              '"valid": true,'\
              '"type": "cname",'\
              '"host": "7.example.com",'\
              '"data": "sendgrid.net"'\
            '}'\
          '}'\
        '}'
      end

      let(:result) do
        '{'\
          '"id": 1,'\
          '"valid": true,'\
          '"validation_results": {'\
            '"domain_cname": {'\
              '"valid": false,'\
              '"reason": "Expected CNAME to match '\
                '\"sendgrid.net.\" but found'\
              ' \"example.com.\"."'\
            '},'\
            '"owner_cname": {'\
              '"valid": true,'\
              '"reason": null'\
            '}'\
          '}'\
        '}'
      end

      it '#get_wl_links' do
        allow(client).to receive(:execute).and_return(links)
        actual = client.get_wl_links
        expect(actual).to be_a(Array)
      end

      it '#post_wl_link' do
        allow(client).to receive(:execute).and_return(link)
        actual = client.post_wl_link(domain: '', subdomain: '')
        expect(actual).to be_a(Links::Link)
      end

      it '#get_wl_link' do
        allow(client).to receive(:execute).and_return(link)
        actual = client.get_wl_link(id: '')
        expect(actual).to be_a(Links::Link)
      end

      it '#patch_wl_link' do
        allow(client).to receive(:execute).and_return(link)
        actual = client.patch_wl_link(id: '', default: true)
        expect(actual).to be_a(Links::Link)
      end

      it '#delete_wl_link' do
        allow(client).to receive(:execute).and_return('')
        actual = client.delete_wl_link(id: '')
        expect(actual).to eq('')
      end

      it '#get_default_wl_link' do
        allow(client).to receive(:execute).and_return(link)
        actual = client.get_default_wl_link(domain: '')
        expect(actual).to be_a(Links::Link)
      end

      it '#validate_link' do
        allow(client).to receive(:execute).and_return(result)
        actual = client.validate_wl_link(id: '')
        expect(actual).to be_a(Links::Result)
      end

      it '#get_associated_wl_link' do
        allow(client).to receive(:execute).and_return(link)
        actual = client.get_associated_wl_link(username: '')
        expect(actual).to be_a(Links::Link)
      end

      it '#disassociate_wl_link' do
        allow(client).to receive(:execute).and_return('')
        actual = client.disassociate_wl_link(username: '')
        expect(actual).to eq('')
      end

      it '#associate_wl_link' do
        allow(client).to receive(:execute).and_return(link)
        actual = client.associate_wl_link(id: '', username: '')
        expect(actual).to be_a(Links::Link)
      end

      it 'creates link instance' do
        actual = Links.create_link(JSON.parse(link))
        expect(actual).to be_a(Links::Link)
        expect(actual.id).to eq(1)
        expect(actual.domain).to eq('example.com')
        expect(actual.subdomain).to eq('mail')
        expect(actual.username).to eq('john@example.com')
        expect(actual.user_id).to eq(7)
        expect(actual.default).to eq(false)
        expect(actual.valid).to eq(true)
        expect(actual.legacy).to eq(false)
        expect(actual.dns).to be_a(Links::Dns)
        expect(actual.dns.domain_cname).to be_a(Links::Record)
        expect(actual.dns.domain_cname.host).to eq('mail.example.com')
        expect(actual.dns.domain_cname.type).to eq('cname')
        expect(actual.dns.domain_cname.data).to eq('sendgrid.net')
        expect(actual.dns.domain_cname.valid).to eq(true)
        expect(actual.dns.owner_cname).to be_a(Links::Record)
        expect(actual.dns.owner_cname.host).to eq('7.example.com')
        expect(actual.dns.owner_cname.type).to eq('cname')
        expect(actual.dns.owner_cname.data).to eq('sendgrid.net')
        expect(actual.dns.owner_cname.valid).to eq(true)
      end

      it 'creates result instance' do
        actual = Links.create_result(JSON.parse(result))
        expect(actual).to be_a(Links::Result)
        expect(actual.id).to eq(1)
        expect(actual.valid).to eq(true)
        expect(actual.validation_results).to be_a(Links::ValidationResults)
        expect(actual.validation_results.domain_cname).to be_a(
          Links::ValidationResult
        )
        expect(actual.validation_results.domain_cname.valid).to be(false)
        expect(actual.validation_results.domain_cname.reason).to be_a(String)
        expect(actual.validation_results.owner_cname).to be_a(
          Links::ValidationResult
        )
        expect(actual.validation_results.owner_cname.valid).to be(true)
        expect(actual.validation_results.owner_cname.reason).to be(nil)
      end
    end
  end
end
