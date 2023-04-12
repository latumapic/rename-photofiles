# rename-photofiles
This is a PowerShell script that renames JPEG image files in the specified directory from Exif information.

スクリプトには、以下のパラメータがあります。

$srcPath：対象ファイルが格納されたディレクトリのパス。
$baseFileName：Exif からカメラ名を取得できなかった場合に、ファイルに付ける名前のベースとなる文字列。
$limitNumberDigits：同一ファイル名になった場合に、付ける連番の桁数。0 に設定すると、同一ファイルがあった場合には処理しません。
$divFolder：リネーム後、年月ごとにファイルをフォルダ分けするかどうかを指定するブール値。$true に設定すると分けます。
スクリプトの動作は以下の通りです。

$srcPath で指定されたディレクトリ以下の JPEG 画像ファイルを取得します。
画像ファイルから Exif 情報を読み込み、カメラのモデル名と生成日時を取得します。
カメラのモデル名が取得できなかった場合には、$baseFileName をファイル名のベースとして使用します。
取得した生成日時をファイル名に加え、リネームします。同一ファイル名がある場合は、$limitNumberDigits で指定した桁数の連番を付加します。
$divFolder が $true に設定されている場合は、年月ごとにフォルダを分けてファイルを移動します。
以上の処理を、ディレクトリ以下の全ての JPEG 画像ファイルに対して行います。
