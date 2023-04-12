Add-Type -AssemblyName System.Drawing

# パラメータ
[string]$srcPath="C:\Temp\photo" # 対象ファイルのパス
[string]$baseFileName="unknown"  # Exifからカメラ名を取得できなかったときにファイルに付ける名前のベース
[int]$limitNumberDigits=1        # 同一ファイル名になったときに付ける連番の桁数（0だと同一ファイルがあったときは処理しない）
[boolean]$divFolder=$true        # リネーム後、年月ごとにファイルをフォルダ分けするか（する：$true / しない：$false）

# 変数
[int]$limitNumber=[Math]::Pow(10,$limitNumberDigits)
[string]$numberFormat="0"
$numberFormat*=$limitNumberDigits

# 画像読み込み
gci -Recurse $srcPath -include *.jpg, *.jpeg | sort LastWriteTime | ? { !$_.PSIsContainer } | ForEach-Object {
    $file = $_
    $img = New-Object Drawing.Bitmap($file.fullname) # フルパスで指定

    # オリジナル画像データのカメラのモデル(272)を取得
    [byte[]]$byteAry = ($img.PropertyItems | Where-Object{$_.Id -eq 272}).Value
    if ($byteAry -ne $null) {
        $baseFileName=[System.Text.Encoding]::ASCII.GetString($byteAry) # バイト配列を文字列に変換
        $baseFileName=$baseFileName.substring(0,$baseFileName.Length-1)
    }

    # オリジナル画像データの生成日時(36867)を取得
    [byte[]]$byteAry = ($img.PropertyItems | Where-Object{$_.Id -eq 36867}).Value

    if ($byteAry -ne $null) {
        # 「yyyy:MM:dd HH:mm:ss」 → 
        # 「yyyy/MM/dd HH:mm:ss」になるよう年月日の区切りを「/」で上書き
        $byteAry[4] = 47
        $byteAry[7] = 47

        # 取得した日時を表示
        $fileDate=[datetime][System.Text.Encoding]::ASCII.GetString($byteAry) # バイト配列を文字列に変換
        $kindMark="E"
    } else {
        # 取得できないときは、最終更新日
        $fileDate=$file.LastWriteTime
        $kindMark="F"
    }
    $img.Dispose()
    $img = $null

    # set newFolder
    if ($divFolder -eq $true) {
        $TrgtFolder = "${srcPath}\$($fileDate.ToString("yyyyMM"))"
        if (![System.IO.Directory]::Exists($TrgtFolder)) {
            new-item $TrgtFolder -ItemType Directory
        }
    } else {
        $TrgtFolder = $file.DirectoryName
    }

    # set newFileName
    [string]$newBaseFileName="${baseFileName}_${kindMark}$($fileDate.ToString("yyyyMMdd_HHmmss"))"
    [string]$newBaseFileExtension=$file.Extension
    [string]$newFileName="${newBaseFileName}${newBaseFileExtension}"

    # 同一ファイル名のデータがあれば連番付加
    if ([IO.Path]::GetDirectoryName($file.FullName) -eq $TrgtFolder) {
        $arrTrgtFolderFile=$(gci $TrgtFolder -Exclude $file.Name | ? { !$_.PSIsContainer }).Name
    } else {
        $arrTrgtFolderFile=$(gci $TrgtFolder | ? { !$_.PSIsContainer }).Name
    }
    [int]$i=0
    if (![string]::IsNullOrEmpty($arrTrgtFolderFile) -or [IO.Path]::GetDirectoryName($file.FullName) -ne $TrgtFolder) {
        while(++$i -le $limitNumber) {
            if ($arrTrgtFolderFile -contains $newFileName) {
                $newFileName="${newBaseFileName}_$($i.ToString($numberFormat))${newBaseFileExtension}"
            } else {
                break
            }
        }
    }
    # 出力ファイル名が設定で来たら実行。そうでなければ処理を行わない
    if ($i -le $limitNumber -and $file.name -ne $newFileName) {
        # 新しいファイル名で出力
        Move-Item $file.FullName "${TrgtFolder}\${newFileName}"
    }
}
