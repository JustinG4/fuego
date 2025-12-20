'use client';

import { useState, useEffect } from 'react';
import { X, Plus, Trash2, Image as ImageIcon } from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface Milestone {
  id: string;
  name: string;
  tier_id: string;
}

interface ProductCreateModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  tenantId: string;
}

export default function ProductCreateModal({
  isOpen,
  onClose,
  onSuccess,
  tenantId,
}: ProductCreateModalProps) {
  const [milestones, setMilestones] = useState<Milestone[]>([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    handle: '',
    price: 0,
    compare_at_price: null as number | null,
    currency: 'USD',
    images: [] as string[],
    thumbnail_url: '',
    available_for_sale: true,
    quantity_available: null as number | null,
    required_milestone_ids: [] as string[],
    unlock_logic: 'all',
    is_limited_edition: false,
    category: '',
    tags: [] as string[],
  });

  useEffect(() => {
    if (isOpen) {
      loadMilestones();
    }
  }, [isOpen, tenantId]);

  async function loadMilestones() {
    const { data } = await supabase
      .from('milestones')
      .select('id, name, tier_id')
      .eq('tenant_id', tenantId)
      .order('display_order');

    if (data) {
      setMilestones(data);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);

    try {
      // Generate handle from name if not provided
      const handle = formData.handle || formData.name.toLowerCase().replace(/\s+/g, '-');

      const { error } = await supabase.from('products').insert({
        tenant_id: tenantId,
        ...formData,
        handle,
      });

      if (error) throw error;

      // Reset form
      setFormData({
        name: '',
        description: '',
        handle: '',
        price: 0,
        compare_at_price: null,
        currency: 'USD',
        images: [],
        thumbnail_url: '',
        available_for_sale: true,
        quantity_available: null,
        required_milestone_ids: [],
        unlock_logic: 'all',
        is_limited_edition: false,
        category: '',
        tags: [],
      });

      onSuccess();
      onClose();
    } catch (error: any) {
      console.error('Error creating product:', error);
      alert('Error creating product: ' + error.message);
    } finally {
      setLoading(false);
    }
  }

  function toggleMilestone(milestoneId: string) {
    setFormData(prev => ({
      ...prev,
      required_milestone_ids: prev.required_milestone_ids.includes(milestoneId)
        ? prev.required_milestone_ids.filter(id => id !== milestoneId)
        : [...prev.required_milestone_ids, milestoneId],
    }));
  }

  function addImage() {
    const url = prompt('Enter image URL:');
    if (url) {
      setFormData(prev => ({
        ...prev,
        images: [...prev.images, url],
        thumbnail_url: prev.thumbnail_url || url,
      }));
    }
  }

  function removeImage(index: number) {
    setFormData(prev => ({
      ...prev,
      images: prev.images.filter((_, i) => i !== index),
    }));
  }

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen px-4 py-8">
        <div className="fixed inset-0 bg-black/50" onClick={onClose}></div>

        <div className="relative bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-3xl w-full p-6 max-h-[90vh] overflow-y-auto">
          <div className="flex justify-between items-center mb-6 sticky top-0 bg-white dark:bg-gray-800 pb-4 border-b border-gray-200 dark:border-gray-700">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Create New Product
            </h2>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Basic Info */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Product Name
              </label>
              <input
                type="text"
                required
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="e.g., SPARK Performance Tee"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Description
              </label>
              <textarea
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="Product description..."
                rows={3}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Handle (URL slug)
                </label>
                <input
                  type="text"
                  value={formData.handle}
                  onChange={(e) => setFormData({ ...formData, handle: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="auto-generated from name"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Category
                </label>
                <input
                  type="text"
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="e.g., Apparel"
                />
              </div>
            </div>

            {/* Pricing */}
            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Price
                </label>
                <input
                  type="number"
                  required
                  min="0"
                  step="0.01"
                  value={formData.price}
                  onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Compare at Price
                </label>
                <input
                  type="number"
                  min="0"
                  step="0.01"
                  value={formData.compare_at_price || ''}
                  onChange={(e) => setFormData({ ...formData, compare_at_price: e.target.value ? parseFloat(e.target.value) : null })}
                  className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Quantity
                </label>
                <input
                  type="number"
                  min="0"
                  value={formData.quantity_available || ''}
                  onChange={(e) => setFormData({ ...formData, quantity_available: e.target.value ? parseInt(e.target.value) : null })}
                  className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="Unlimited"
                />
              </div>
            </div>

            {/* Images */}
            <div>
              <div className="flex justify-between items-center mb-3">
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                  Product Images
                </label>
                <button
                  type="button"
                  onClick={addImage}
                  className="text-sm text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 flex items-center gap-1"
                >
                  <Plus className="w-4 h-4" />
                  Add Image URL
                </button>
              </div>

              <div className="grid grid-cols-3 gap-3">
                {formData.images.map((url, index) => (
                  <div key={index} className="relative group">
                    <img
                      src={url}
                      alt={`Product ${index + 1}`}
                      className="w-full h-32 object-cover rounded-lg border border-gray-300 dark:border-gray-600"
                      onError={(e) => {
                        (e.target as HTMLImageElement).src = 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect fill="%23ddd" width="200" height="200"/><text x="50%" y="50%" text-anchor="middle" dy=".3em" fill="%23999">No Image</text></svg>';
                      }}
                    />
                    <button
                      type="button"
                      onClick={() => removeImage(index)}
                      className="absolute top-2 right-2 p-1 bg-red-500 text-white rounded opacity-0 group-hover:opacity-100 transition-opacity"
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </div>
                ))}
                {formData.images.length === 0 && (
                  <div className="col-span-3 flex items-center justify-center h-32 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg">
                    <div className="text-center text-gray-500 dark:text-gray-400">
                      <ImageIcon className="w-8 h-8 mx-auto mb-2" />
                      <p className="text-sm">No images yet</p>
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Required Milestones */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
                Required Milestones (optional)
              </label>
              <div className="max-h-48 overflow-y-auto border border-gray-300 dark:border-gray-600 rounded-lg p-3 space-y-2">
                {milestones.map((milestone) => (
                  <label
                    key={milestone.id}
                    className="flex items-center gap-2 p-2 hover:bg-gray-50 dark:hover:bg-gray-700 rounded cursor-pointer"
                  >
                    <input
                      type="checkbox"
                      checked={formData.required_milestone_ids.includes(milestone.id)}
                      onChange={() => toggleMilestone(milestone.id)}
                      className="w-4 h-4 text-indigo-600 rounded"
                    />
                    <span className="text-sm text-gray-700 dark:text-gray-300">{milestone.name}</span>
                  </label>
                ))}
                {milestones.length === 0 && (
                  <p className="text-sm text-gray-500 dark:text-gray-400 text-center py-4">
                    No milestones available. Create milestones first.
                  </p>
                )}
              </div>
            </div>

            {/* Flags */}
            <div className="flex gap-6">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.available_for_sale}
                  onChange={(e) => setFormData({ ...formData, available_for_sale: e.target.checked })}
                  className="w-4 h-4 text-indigo-600 rounded"
                />
                <span className="ml-2 text-sm text-gray-700 dark:text-gray-300">Available for Sale</span>
              </label>

              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.is_limited_edition}
                  onChange={(e) => setFormData({ ...formData, is_limited_edition: e.target.checked })}
                  className="w-4 h-4 text-indigo-600 rounded"
                />
                <span className="ml-2 text-sm text-gray-700 dark:text-gray-300">Limited Edition</span>
              </label>
            </div>

            {/* Actions */}
            <div className="flex gap-3 pt-4 border-t border-gray-200 dark:border-gray-700 sticky bottom-0 bg-white dark:bg-gray-800">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={loading}
                className="flex-1 px-4 py-2 bg-gradient-to-r from-indigo-600 to-purple-600 text-white rounded-lg hover:from-indigo-700 hover:to-purple-700 disabled:opacity-50"
              >
                {loading ? 'Creating...' : 'Create Product'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
