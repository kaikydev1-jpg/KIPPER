package org.cutwire.drift;

import androidx.core.content.FileProvider;

// Kipper: o FileProvider só da pasta de atualizações (res/xml/kipper_update_paths.xml). Uma
// subclasse, porque o Qt já declara o FileProvider dele com outra lista de pastas.
public final class KipperUpdateProvider extends FileProvider {
}
