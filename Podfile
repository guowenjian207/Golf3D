# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'MatchItUp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MatchItUp
    pod 'Masonry'
    pod 'AFNetworking'
    pod 'SwipeCellKit'
    pod 'LMJDropdownMenu'
    pod 'MBProgressHUD'
    pod 'SDWebImage'
    pod 'LookinServer', :configurations => ['Debug']
    pod 'SSZipArchive'
    pod 'FBMemoryProfiler'
    pod 'AFNetworking'
    pod 'TZImagePickerController'
    pod 'OpenCV'

  target 'MatchItUpTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MatchItUpUITests' do
    # Pods for testing
  end

end
post_install do|installer|
   #解决问题一
   find_and_replace("Pods/FBRetainCycleDetector/FBRetainCycleDetector/Layout/Classes/FBClassStrongLayout.mm",
       "layoutCache[currentClass] = ivars;", "layoutCache[(id)currentClass] = ivars;")
   #解决问题二
   find_and_replace("Pods/FBRetainCycleDetector/fishhook/fishhook.c",
   "indirect_symbol_bindings[i] = cur->rebindings[j].replacement;", "if (i < (sizeof(indirect_symbol_bindings) /
        sizeof(indirect_symbol_bindings[0]))) { \n indirect_symbol_bindings[i]=cur->rebindings[j].replacement; \n }")
    #解决问题三
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
  installer.pods_project.targets.each do |target|
      shell_script_path = "Pods/Target Support Files/#{target.name}/#{target.name}-frameworks.sh"
      if File::exists?(shell_script_path)
        shell_script_input_lines = File.readlines(shell_script_path)
        shell_script_output_lines = shell_script_input_lines.map { |line| line.sub("source=\"$(readlink \"${source}\")\"", "source=\"$(readlink -f \"${source}\")\"") }
        File.open(shell_script_path, 'w') do |f|
          shell_script_output_lines.each do |line|
            f.write line
          end
        end
      end
    end
end
def find_and_replace(dir, findstr, replacestr)
  Dir[dir].each do |name|
    FileUtils.chmod("+w",name) #add
      text = File.read(name)
      replace = text.gsub(findstr,replacestr)
      if text != replace
         puts "Fix: " + name
         File.open(name, "w") { |file| file.puts replace }
         STDOUT.flush
      end
  end
  Dir[dir + '*/'].each(&method(:find_and_replace))
end
