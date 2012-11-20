require 'formula'

class DmgDownloadStrategy < CurlDownloadStrategy
  def stage
    begin
      tmp = ENV['HOMEBREW_TEMP'].chuzzle || '/tmp'
      tempd = Pathname.new(`/usr/bin/mktemp -d #{tmp}/#{@tarball_path.basename}-XXXX`.chuzzle)

      quiet_system 'hdiutil', 'attach', '-mountpoint', tempd, @tarball_path
      # Use globbing to exclude some dotfiles which have wacky permissions.
      FileUtils.cp_r Dir[tempd/'*'], Pathname.pwd
    ensure
      ignore_interrupts do
        quiet_system 'hdiutil', 'detach', tempd
        FileUtils.rm_r tempd
      end if tempd
    end

    chdir
  end
end


class Kakadu < Formula
  homepage 'http://www.kakadusoftware.com'
  url 'http://www.kakadusoftware.com/executables/OSX106.dmg'
  version '7.1'
  sha1 '86540246f1e3d7704abf41ec87b6890211006c1b'

  def download_strategy; DmgDownloadStrategy end

  def install
    system 'pkgutil', '--expand', 'Kakadu-demo-apps.pkg', 'pkgs'

    mkdir 'stage' do
      Dir['../pkgs/*.pkg/Payload'].each do |p|
        system 'pax', '--insecure', '-rz', '-f', p
      end
      lib.install Dir['*.dylib']
      (prefix + 'Applications').install Dir['*.app']
      bin.install Dir['*']
    end
  end

  def caveats
    <<-EOS.undent
      The Kakadu software is covered by a commercial license that allows for
      non-commercial evaluation uses only. See the following website for
      details:

        http://www.kakadusoftware.com/index.php?option=com_content&task=view&id=26&Itemid=22
      EOS
  end

  def test
    system 'kdu_expand', '-v'
  end
end
