# -*- coding: utf-8 -*-
require 'spec_helper'

describe DXRubySDL::Input,
         'キーボード・ゲームパッド・マウスの入力を扱うモジュール' do
  after do
    DXRubySDL::Input.instance_variable_set('@joysticks', [])
  end

  shared_context 'push_key' do
    let(:_keys) { [] }

    before do
      allow(SDL::Key).to receive(:scan)
      allow(SDL::Key).to receive(:press?) { |key|
                           [_keys].flatten.include?(key) ? true : false
                         }
    end
  end

  describe '.x' do
    include_context 'push_key'

    subject { described_class.x }

    context '左カーソルが押されている場合' do
      let(:_keys) { SDL::Key::LEFT }

      it { should eq(-1) }
    end

    context '右カーソルが押されている場合' do
      let(:_keys) { SDL::Key::RIGHT }

      it { should eq(1) }
    end

    context '左・右カーソルが両方とも押されている場合' do
      let(:_keys) { [SDL::Key::LEFT, SDL::Key::RIGHT] }

      it { should eq(0) }
    end

    context '左・右カーソルのどちらも押されていない場合' do
      it { should eq(0) }
    end
  end

  describe '.y' do
    include_context 'push_key'

    subject { described_class.y }

    context '上カーソルが押されている場合' do
      let(:_keys) { SDL::Key::UP }

      it { should eq(-1) }
    end

    context '下カーソルが押されている場合' do
      let(:_keys) { SDL::Key::DOWN }

      it { should eq(1) }
    end

    context '上・下カーソルが両方とも押されている場合' do
      let(:_keys) { [SDL::Key::UP, SDL::Key::DOWN] }

      it { should eq(0) }
    end

    context '上・下カーソルのどちらも押されていない場合' do
      it { should eq(0) }
    end
  end

  describe '.pad_down?', 'パッドのボタン状態を返す' do
    include_context 'push_key'

    context 'Joystickが接続されている場合' do
      let(:joystick) {
        j = double('Joystick')
        allow(j).to receive(:button).with(anything).and_return(false)
        j
      }

      before do
        allow(SDL::Joystick).to receive(:num).and_return(1)
        allow(SDL::Joystick).to receive(:open).with(0).and_return(joystick)
      end

      describe '0番目(P_BUTTON0)のボタン' do
        subject { described_class.pad_down?(DXRubySDL::P_BUTTON0) }

        context '0番目のボタンが押されている場合' do
          let(:joystick) {
            j = double('Joystick')
            allow(j).to receive(:button) { |button_index|
                          button_index == DXRubySDL::P_BUTTON0
                        }
            j
          }

          it { should be_true }
        end

        context 'Zキーが押されている場合' do
          let(:_keys) { SDL::Key::Z }

          it { should be_true }
        end

        context 'ボタンやキーが押されていない場合' do
          it { should be_false }
        end
      end
    end

    context 'Joystickが接続されていない場合' do
      before do
        allow(SDL::Joystick).to receive(:num).and_return(0)
      end

      describe '0番目(P_BUTTON0)のボタン' do
        subject { described_class.pad_down?(DXRubySDL::P_BUTTON0) }

        context 'Zキーが押されている場合' do
          let(:_keys) { SDL::Key::Z }

          it { should be_true }
        end

        context 'ボタンやキーが押されていない場合' do
          it { should be_false }
        end
      end
    end
  end
end
