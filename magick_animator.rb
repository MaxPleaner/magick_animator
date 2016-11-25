require 'active_support/all'

class MagickAnimator

  SOURCES=ARGV

  MAGICK_COMMANDS = {
    blend_images: [
      "-blend ${i}0",
      "/tmp/b.gif",
      "/tmp/a.gif",
      "/tmp/c${i}0.gif"
    ]
  }

  def self.test
    new.animate(
      magick_cmds: MAGICK_COMMANDS.get(:blend_images),
      n_frames: 3,
      frame_ms: 500,
      dest: "foo.gif",
      sources: SOURCES
    )
  end

  def animate(magick_cmds:, n_frames:, frame_ms:, dest:, sources:)
    create_frames magick_cmds, n_frames
    combine_frames n_frames, frame_ms, des, sources
  end

  def create_frames(magick_cmds, n_frames)
    system <<-SH.strip_heredoc
      for i in ${seq #{n_frames}}
      do \
        composite \
        #{magick_cmds.join(" ")}
      done
    SH
  end

  def combine_frames(n_frames, frame_ms, dest, sources)
    system <<-SH.strip_heredoc
      convert \
        -delay #{frame_ms}
        -dispose None \
        /tmp/c?0.gif \
        /tmp/c${n_frames}.gif \
        - loop 1 \
        #{dest}
    SH
  end

  private

    def envvar(name)
      ENV["NAME"] || raise(StandardError, "missing env var #{name}")
    end

end
