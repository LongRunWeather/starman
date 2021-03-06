class OdbApi < Package
  url 'https://software.ecmwf.int/wiki/download/attachments/61117379/odb_api_bundle-0.18.0-Source.tar.gz?api=v2'
  sha256 '9cab8fc4adf31c41651694bcfa8fa846a8972e7a0d4c15729cd70c834b92fa5c'

  depends_on :yacc
  depends_on :ncurses
  depends_on :eccodes
  depends_on :netcdf

  option 'with-python', 'Build Python2 bindings.'

  def install
    args = std_cmake_args search_paths: [Eccodes.link_root]
    args << '-DENABLE_NETCDF=On'
    args << '-DENABLE_FORTRAN=On'
    args << "-DENABLE_PYTHON=#{with_python? ? 'On' : 'Off'}"
    args << "-DNETCDF_PATH='#{link_inc}'"
    if OS.mac?
      inreplace 'odb_api/CMakeLists.txt', 'ecbuild_add_cxx_flags("-fPIC -Wl,--as-needed")', 'ecbuild_add_cxx_flags("-fPIC")'
    end
    mkdir 'build' do
      run 'cmake', '..', *args
      run 'make', 'install'
    end
  end
end
