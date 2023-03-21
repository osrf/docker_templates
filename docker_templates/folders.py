import os
import shutil
import string

try:
    from cStringIO import StringIO
except ImportError:
    from io import StringIO
from em import Interpreter


class AltTemplate(string.Template):
    delimiter = '@'
    idpattern = r'[a-z][_a-z0-9]*'


def interpret_tempate(tempate, data):

    output = StringIO()
    try:
        interpreter = Interpreter(output=output)
        interpreter.file(open(tempate, 'r'), locals=data)
        output = output.getvalue()
    except Exception as e:
        print("Error processing %s" % tempate)
        raise
    finally:
        interpreter.shutdown()
        interpreter = None

    return output


def populate_path(data, path):
    if not os.path.exists(path):
        os.makedirs(path)

    templates = data['templates']

    makefile = interpret_tempate(templates['makefile'], data)
    makefile_path = os.path.join(path, "Makefile")
    with open(makefile_path, 'w') as f:
        f.write(makefile)

    platform = interpret_tempate(templates['platform'], data)
    platform_path = os.path.join(path, "platform.yaml")
    with open(platform_path, 'w') as f:
        f.write(platform)

    shutil.copy(templates['images'], path)


def populate_paths(manifest, args, create_dockerfiles):
    # For each release
    for release_name, release_data in manifest['release_names'].items():
        # For each os supported
        for os_name, os_data in release_data['os_names'].items():
            # For each os distro supported
            for os_code_name, os_code_data in os_data['os_code_names'].items():
                if os_code_data['tag_names'] is None:
                    continue
                dockerfolder_dir = os.path.join(release_name, os_name, os_code_name)

                os_code_data['release_name'] = release_name
                os_code_data['os_name'] = os_name
                os_code_data['os_code_name'] = os_code_name
                os_code_data['archs'] = os_code_data['archs']

                populate_path(data=os_code_data, path=dockerfolder_dir)

                if args.auto:
                    # Run the dockerfile generation script
                    create_dockerfiles.main(('dir', '-d' + dockerfolder_dir))
