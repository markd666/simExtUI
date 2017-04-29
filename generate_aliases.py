from lxml import etree
from sys import argv, exit
from time import strftime

if len(argv) != 2:
    print('usage: {} <outfile.lua>'.format(argv[0]))
    exit(1)

with open(argv[1],'w') as outfile:
    tree = etree.parse('callbacks.xml')
    root = tree.getroot()
    pluginName = root.attrib['name']
    shortName = root.attrib['short-name'] if 'short-name' in root.attrib else pluginName
    outfile.write('-- generated by {} on {}\n'.format(argv[0], strftime('%d/%m/%Y')))
    outfile.write('-- do not edit\n\n')
    outfile.write('local {shortName}={{}}\n'.format(**locals()))
    for e in root.findall('command'):
        if e.tag != 'command': continue
        cmdName = e.attrib['name']
        outfile.write('{shortName}.{cmdName}=simExt{pluginName}_{cmdName}\n'.format(**locals()))
    outfile.write('return {shortName}\n'.format(**locals()))
