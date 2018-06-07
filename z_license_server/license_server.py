# -*- coding: utf-8 -*-
import os
import datetime
from flask import Flask, request, url_for, send_from_directory
from werkzeug import secure_filename

ALLOWED_EXTENSIONS = set(['key'])

app = Flask(__name__)
#当前工作目录
app.config['UPLOAD_FOLDER'] = os.getcwd()
app.config['DOWNLOAD_FOLDER'] = os.path.join(os.getcwd(), "xsky-licenses/")
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024
app.config['SERVER_IP'] = '0.0.0.0'
env_dist = os.environ
app.config['HOST_IP'] = env_dist.get('HOST_IP')

html = '''
    <!DOCTYPE html>
    <title>zs-ceph-license</title>
    <meta charset='utf-8'/>
    <h1>ZStack企业级ceph存储license自助申请</h1>
    <form method=post enctype=multipart/form-data>
         <br>申请人: <input type=text placeholder="zhaohao.chen" name=sID>
         &emsp;集群密钥文件: <input type=file name=file>
         <br><input type=submit value=提交>
    </form>
    '''

def apply_license(filename):
    license_name = "{}".format(filename)
    os.system("bash xsky-license.sh -c 10 -d 30 -p 'X-EBS Basic' -k {} > {}{}".format(filename, app.config['DOWNLOAD_FOLDER'], license_name))
    return "http://{}/download/{}".format(app.config['HOST_IP'], license_name)
	
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/download/<filename>')
def download_file(filename):
    return send_from_directory(app.config['DOWNLOAD_FOLDER'], filename, as_attachment=True)

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        try:
            file = request.files['file']
            sID = request.form.get('sID')
            print sID
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                uufilename = sID+'-'+str(datetime.datetime.now()).split()[1]+'-'+filename
                file.save(os.path.join(app.config['UPLOAD_FOLDER'], uufilename))
                return html + '<br><a href="' + apply_license(uufilename) + '">license-{0}</a>'.format(sID)
        finally:
            os.system("rm -f -- {}".format(uufilename))
    return html
    
if __name__ == '__main__':
    app.run(host=app.config['SERVER_IP'], port=80, debug=True)
