class Document < ActiveRecord::Base
  ### Constants
  VISIBILITY_OPTIONS = %w[sysadmins reporters public]

  ### Attributes
  attr_accessible :title, :document, :visibility, :description

  ### Attachments
  has_attached_file :document, Settings.paperclip.to_options

  ### Validations
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_attachment_presence :document
  validates_attachment_size :document, :less_than => 10.megabytes,
                            :message => "must be less than 10MB"
  validates_inclusion_of :visibility, :in => VISIBILITY_OPTIONS

  ### Named Scopes
  named_scope :latest_first, {:order => "created_at DESC" }
  named_scope :limited, {:limit => 5}
  named_scope :visible_to_reporters, :conditions => ["visibility = ? OR visibility = ?",
                                                     'public', 'reporters']
  named_scope :visible_to_public, :conditions => ["visibility = ?", 'public']

end
