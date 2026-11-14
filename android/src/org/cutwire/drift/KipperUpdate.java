package org.cutwire.drift;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import java.io.File;

// Kipper: abre o instalador do Android com o APK da versão nova, já baixado e conferido pelo
// SHA-256 no lado C++ (UpdateChecker). O Android mostra "Atualizar este app?" e, na primeira vez,
// pede para permitir instalar apps do Kipper. Só instala por cima se a assinatura for a mesma.
public final class KipperUpdate {
    private KipperUpdate() {}

    public static boolean installApk(Context context, String path) {
        try {
            File apk = new File(path);
            if (!apk.isFile())
                return false;
            Uri uri = KipperUpdateProvider.getUriForFile(
                    context, context.getPackageName() + ".kipperupdate", apk);
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(uri, "application/vnd.android.package-archive");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            return true;
        } catch (IllegalArgumentException | ActivityNotFoundException | SecurityException e) {
            return false;
        }
    }
}
