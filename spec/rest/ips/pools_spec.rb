# encoding: utf-8
require File.dirname(__FILE__) + '/../../spec_helper'

module SendGrid4r::REST::Ips
  describe Pools do
    describe 'integration test', :it do
      before do
        Dotenv.load
        @client = SendGrid4r::Client.new(api_key: ENV['SILVER_API_KEY'])
        @pool_name1 = 'pool_test1'
        @pool_name2 = 'pool_test2'
        @pool_edit1 = 'pool_edit1'

        # clean up test env
        pools = @client.get_pools
        pools.each do |pool|
          @client.delete_pool(name: pool.name) if pool.name == @pool_name1
          @client.delete_pool(name: pool.name) if pool.name == @pool_name2
          @client.delete_pool(name: pool.name) if pool.name == @pool_edit1
        end
        # post a pool
        @client.post_pool(name: @pool_name1)
      end

      context 'account is silver' do
        context 'without block call' do
          it '#post_pool' do
            new_pool = @client.post_pool(name: @pool_name2)
            expect(new_pool.name).to eq(@pool_name2)
          end

          it '#get_pools' do
            pools = @client.get_pools
            expect(pools.length).to be > 0
            pools.each do |pool|
              expect(pool).to be_a(Pools::Pool)
              expect(pool.name).to be_a(String)
            end
          end

          it '#get_pool' do
            pool = @client.get_pool(name: @pool_name1)
            expect(pool).to be_a(Pools::Pool)
            expect(pool.pool_name).to eq(@pool_name1)
            expect(pool.ips).to be_a(Array)
          end

          it '#put_pool' do
            edit_pool = @client.put_pool(
              name: @pool_name1, new_name: @pool_edit1
            )
            expect(edit_pool.name).to eq(@pool_edit1)
          end

          it '#delete_pool' do
            @client.delete_pool(name: @pool_name1)
          end
        end
      end
    end

    describe 'unit test', :ut do
      let(:client) do
        SendGrid4r::Client.new(api_key: '')
      end

      let(:pool) do
        '{'\
          '"ips":["167.89.21.3"],'\
          '"name":"new_test5"'\
        '}'
      end

      let(:pools) do
        '['\
          '{'\
            '"name": "test1"'\
          '},'\
          '{'\
            '"name": "test2"'\
          '},'\
          '{'\
            '"name": "test3"'\
          '},'\
          '{'\
            '"name": "new_test3"'\
          '}'\
        ']'
      end

      it '#post_pool' do
        allow(client).to receive(:execute).and_return(pool)
        actual = client.post_pool(name: '')
        expect(actual).to be_a(Pools::Pool)
      end

      it '#get_pools' do
        allow(client).to receive(:execute).and_return(pools)
        actual = client.get_pools
        expect(actual).to be_a(Array)
        actual.each do |pool|
          expect(pool).to be_a(Pools::Pool)
        end
      end

      it '#get_pool' do
        allow(client).to receive(:execute).and_return(pool)
        actual = client.get_pool(name: '')
        expect(actual).to be_a(Pools::Pool)
      end

      it '#put_pool' do
        allow(client).to receive(:execute).and_return(pool)
        actual = client.put_pool(name: '', new_name: '')
        expect(actual).to be_a(Pools::Pool)
      end

      it '#delete_pool' do
        allow(client).to receive(:execute).and_return('')
        actual = client.delete_pool(name: '')
        expect(actual).to eq('')
      end

      it 'creates pool instance with ips' do
        actual = Pools.create_pool(JSON.parse(pool))
        expect(actual).to be_a(Pools::Pool)
        expect(actual.ips).to be_a(Array)
        actual.ips.each do |ip|
          expect(ip).to eq('167.89.21.3')
        end
        expect(actual.name).to eq('new_test5')
      end

      it 'creates pools instances' do
        actual = Pools.create_pools(JSON.parse(pools))
        expect(actual).to be_a(Array)
        actual.each do |pool|
          expect(pool).to be_a(Pools::Pool)
        end
      end
    end
  end
end
