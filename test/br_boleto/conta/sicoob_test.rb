require 'test_helper'

describe BrBoleto::Conta::Sicoob do
	subject { FactoryGirl.build(:conta_sicoob) }

	it "deve herdar de Conta::Base" do
		subject.class.superclass.must_equal BrBoleto::Conta::Base
	end
	context "valores padrões" do
		it "deve setar a carteira com '1' " do
			subject.class.new.carteira.must_equal '1'
		end
		it "deve setar a modalidade com '01' " do
			subject.class.new.modalidade.must_equal '01'
		end
		it "deve setar a modalidade_required com true " do
			subject.class.new.modalidade_required.must_equal true
		end
		it "deve setar a modalidade_length com 2 " do
			subject.class.new.modalidade_length.must_equal 2
		end
		it "deve setar a carteira_required com true " do
			subject.class.new.carteira_required.must_equal true
		end
		it "deve setar a carteira_length com 1 " do
			subject.class.new.carteira_length.must_equal 1
		end
		it "deve setar a conta_corrente_required com true " do
			subject.class.new.conta_corrente_required.must_equal true
		end
		it "deve setar a conta_corrente_maximum com 8 " do
			subject.class.new.conta_corrente_maximum.must_equal 8
		end
		it "deve setar a codigo_cedente_maximum com 7 " do
			subject.class.new.codigo_cedente_maximum.must_equal 7
		end
	end
	describe "Validations" do
		it { must validate_presence_of(:agencia) }
		it { must validate_presence_of(:razao_social) }
		it { must validate_presence_of(:cpf_cnpj) }
		it do
			subject.agencia_dv = 21
			must_be_message_error(:agencia_dv, :custom_length_is, {count: 1})
		end
		
		it 'agencia deve ter 4 digitos' do
			subject.agencia = '123'
			must_be_message_error(:agencia, :custom_length_is, {count: 4})
			subject.agencia = '1234'
			wont_be_message_error(:agencia, :custom_length_is, {count: 4})
		end
		context 'Validações padrões da modalidade' do
			subject { BrBoleto::Conta::Sicoob.new }
			it { must validate_presence_of(:modalidade) }
			it 'Tamanho deve ser de 2' do
				subject.modalidade = '1'
				must_be_message_error(:modalidade, :custom_length_is, {count: 2})
			end
			it "valores aceitos" do
				subject.modalidade = '04'
				must_be_message_error(:modalidade, :custom_inclusion, {list: '01, 02, 03'})
			end
		end
		context 'Validações padrões da carteira' do
			subject { BrBoleto::Conta::Sicoob.new }
			it { must validate_presence_of(:carteira) }
			it 'Tamanho deve ser de 1' do
				subject.carteira = '132'
				must_be_message_error(:carteira, :custom_length_is, {count: 1})
			end
			it "valores aceitos" do
				subject.carteira = '04'
				must_be_message_error(:carteira, :custom_inclusion, {list: '1, 3'})
			end
		end
		context 'Validações padrões da conta_corrente' do
			subject { BrBoleto::Conta::Sicoob.new }
			it { must validate_presence_of(:conta_corrente) }
			it 'Tamanho deve ter o tamanho maximo de 8' do
				subject.conta_corrente = '123456789'
				must_be_message_error(:conta_corrente, :custom_length_maximum, {count: 8})
			end
		end
		context 'Validações padrões da codigo_cedente' do
			subject { BrBoleto::Conta::Sicoob.new }
			it 'Tamanho deve ter o tamanho maximo de 8' do
				subject.codigo_cedente = '123456789'
				must_be_message_error(:convenio, :custom_length_maximum, {count: 7})
			end
		end
	end

	it "codigo do banco" do
		subject.codigo_banco.must_equal '756'
	end
	it '#codigo_banco_dv' do
		subject.codigo_banco_dv.must_equal '0'
	end

	describe "#nome_banco" do
		it "valor padrão para o nome_banco" do
			subject.nome_banco.must_equal 'BANCOOBCED'
		end
		it "deve ser possível mudar o valor do nome do banco" do
			subject.nome_banco = 'MEU'
			subject.nome_banco.must_equal 'MEU'
		end
	end

	it "#versao_layout_arquivo_cnab_240" do
		subject.versao_layout_arquivo_cnab_240.must_equal '081'
	end
	it "#versao_layout_lote_cnab_240" do
		subject.versao_layout_lote_cnab_240.must_equal '040'
	end

	describe '#agencia_dv' do
		it "deve ser personalizavel pelo usuario" do
			subject.agencia_dv = 88
			subject.agencia_dv.must_equal 88
		end
		it "se não passar valor deve calcular automatico" do
			subject.agencia = '1234'
			BrBoleto::Calculos::Modulo11FatorDe2a9RestoZero.expects(:new).with('1234').returns(stub(to_s: 5))

			subject.agencia_dv.must_equal 5
		end
	end


	describe '#conta_corrente_dv' do
		it "deve ser personalizavel pelo usuario" do
			subject.conta_corrente_dv = 88
			subject.conta_corrente_dv.must_equal 88
		end
		it "se não passar valor deve calcular automatico" do
			subject.conta_corrente_dv = nil
			subject.conta_corrente = '6688'
			BrBoleto::Calculos::Modulo11FatorDe2a9RestoZero.expects(:new).with('6688').returns(stub(to_s: 5))

			subject.conta_corrente_dv.must_equal 5
		end
	end

	
end