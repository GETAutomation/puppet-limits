require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'limits::values' do

  let(:title) { 'test_conf' }

  let(:facts) { { :operatingsystem => 'redhat' } }

  let(:params) {
    {
      'domain' => 'oracle',
      'type' => 'soft',
      'item' => 'nofile',
      'value' => '8192',
    }
  }

  it 'should insert a new entry in /etc/security/limits.conf' do
    should contain_augeas('limits.conf/oracle/soft/nofile/eof').with({
      'context' => '/files/etc/security/limits.conf',
      'onlyif'  => 'match #comment[. =~ regexp("End of file")] size > 0',
      'changes' => 'rm #comment[. =~ regexp("End of file")]',
     
    })

    should contain_augeas('limits.conf/oracle/soft/nofile/rm').with({
      'context' => '/files/etc/security/limits.conf',
      'onlyif'  => 'match domain[. = "oracle"][type = "soft" and item = "nofile" and value != "8192"] size > 0',
      'changes' => 'rm domain[. = "oracle"][type = "soft" and item = "nofile"]',
      'before'  => 'Augeas[limits.conf/oracle/soft/nofile/add]',
      
    })

    should contain_augeas('limits.conf/oracle/soft/nofile/add').with({
      'context' => '/files/etc/security/limits.conf',
      'onlyif'  => 'match domain[. = "oracle"][type = "soft" and item = "nofile" and value = "8192"] size == 0',
      'changes' => [
                     "set domain[last()+1] oracle",
                     "set domain[last()]/type soft",
                     "set domain[last()]/item nofile",
                     "set domain[last()]/value 8192"
                   ],
    })
  end

end
