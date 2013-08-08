package MT::Plugin::FaceDetector;

use strict;
use warnings;
use base qw( MT::Plugin );
use Imager;
use Image::ObjectDetect;

our $VERSION = '0.1';
our $PLUGIN_NAME = 'FaceDetector';
our $CASCADE ='/usr/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml';

my $plugin  = __PACKAGE__->new({
    name    => $PLUGIN_NAME,
    version => $VERSION,
    key     => lc $PLUGIN_NAME,
    id      => lc $PLUGIN_NAME,
    author_name => '@onagatani',
    author_link => 'https://www.facebook.com/onagatani',
    description => 'FaceDetector'
});
MT->add_plugin($plugin);
MT->add_callback('CMSUploadImage', 9, $plugin, \&hook_upload);

sub hook_upload {
    my ($eh, %params) = @_;
    my $path = $params{'File'};
    my $detector = Image::ObjectDetect->new($CASCADE);
    my @faces = $detector->detect($path);

    my $image = Imager->new->read(file => $path);
    for my $face (@faces) {
        my $mask = $image->crop(
            left     => $face->{x},
            top      => $face->{y},
            width    => $face->{width},
            height   => $face->{height},
        );
        $mask->filter(type=>"mosaic", size=> 15);
        $image->paste(
            left  => $face->{x},
            top   => $face->{y},
            src   => $mask,
        );
    }
    $image->write(file => $path);
}

1;
__END__
