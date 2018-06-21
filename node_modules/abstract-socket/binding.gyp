{
  'targets': [
    {
      'target_name': 'abstract_socket',
      'sources': [ 'src/abstract_socket.cc' ],
      'include_dirs': [
        '<!(node -e "require(\'nan\')")'
      ]
    }
  ]
}
