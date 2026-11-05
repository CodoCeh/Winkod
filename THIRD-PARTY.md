# Сторонние компоненты Винкода

Винкод содержит программы других авторов. Каждая распространяется на условиях своей лицензии, и лицензия Винкода на них не действует. Тексты лицензий лежат в папке [licenses](licenses) и внутри приложения: `Contents/Resources/Licenses`.

## Движок

| Компонент | Лицензия | Исходный код |
|---|---|---|
| Wine 11.0 (исходники CodeWeavers 26.3.0) | LGPL 2.1 или новее | [Архив](https://media.codeweavers.com/pub/crossover/source/crossover-sources-26.3.0.tar.gz), копия приложена к каждому выпуску |
| cabextract | GPL 3 | В том же архиве, копия приложена к каждому выпуску |
| Wine Mono 10.4.1 | MIT и другие, см. проект | https://github.com/madewokherd/wine-mono |
| DXMT 0.80 | MIT | https://github.com/3Shain/dxmt |
| DXVK 1.10.3 (сборка Gcenx) | zlib | https://github.com/Gcenx/DXVK-macOS |
| winetricks | LGPL 2.1 или новее | https://github.com/Winetricks/winetricks |

Движок собран из исходного кода без изменений в нём. Как это повторить, показывает скрипт [engine/build-engine.sh](engine/build-engine.sh). В нём перечислены все настройки сборки.

Движок не содержит программ из CrossOver. Винкод не связан с CodeWeavers.

## Библиотеки движка

Готовые библиотеки для x86_64 взяты из сборки [Gcenx/macOS_Wine_builds 11.21](https://github.com/Gcenx/macOS_Wine_builds/releases/tag/11.21). Любую из них можно заменить своей версией: они лежат отдельными файлами в `Contents/Resources/wine/lib64`.

| Компонент | Лицензия | Исходный код |
|---|---|---|
| MoltenVK | Apache 2.0 | https://github.com/KhronosGroup/MoltenVK |
| FreeType | FTL | https://freetype.org |
| GnuTLS | LGPL 2.1 или новее | https://gnutls.org |
| Nettle, Hogweed | LGPL 3 или GPL 2 | https://www.lysator.liu.se/~nisse/nettle/ |
| GMP | LGPL 3 или GPL 2 | https://gmplib.org |
| libtasn1 | LGPL 2.1 или новее | https://www.gnu.org/software/libtasn1/ |
| libidn2 | LGPL 3 или GPL 2 | https://www.gnu.org/software/libidn/ |
| libunistring | LGPL 3 или GPL 2 | https://www.gnu.org/software/libunistring/ |
| libiconv | LGPL 2.1 или новее | https://www.gnu.org/software/libiconv/ |
| libintl (gettext) | LGPL 2.1 или новее | https://www.gnu.org/software/gettext/ |
| p11-kit | BSD 3-Clause | https://github.com/p11-glue/p11-kit |
| SDL2 | zlib | https://github.com/libsdl-org/SDL |
| libpcap | BSD 3-Clause | https://github.com/the-tcpdump-group/libpcap |
| libinotify-kqueue | MIT | https://github.com/libinotify-kqueue/libinotify-kqueue |
| libpng | libpng | https://github.com/pnggroup/libpng |
| zlib | zlib | https://github.com/madler/zlib |
| bzip2 | BSD-подобная | https://sourceware.org/bzip2/ |
| Brotli | MIT | https://github.com/google/brotli |
| libffi | MIT | https://github.com/libffi/libffi |
| zstd | BSD | https://github.com/facebook/zstd |
| MacPorts Legacy Support | BSD 3-Clause | https://github.com/macports/macports-legacy-support |

## Инструменты приложения

| Компонент | Лицензия | Исходный код |
|---|---|---|
| socat | GPL 2 | http://www.dest-unreach.org/socat/ |
| zstd | BSD | https://github.com/facebook/zstd |
| OpenSSL | Apache 2.0 | https://github.com/openssl/openssl |
| xz (liblzma) | BSD Zero Clause | https://github.com/tukaani-project/xz |
| lz4 | BSD 2-Clause | https://github.com/lz4/lz4 |

Исходный код компонентов под GPL и LGPL в версии из выпуска можно получить по запросу в разделе [Issues](../../issues) в течение трёх лет после выпуска.
