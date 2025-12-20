'use client';

import { useState, useEffect } from 'react';
import { X, Plus, Trash2 } from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface Tier {
  id: string;
  name: string;
  color: string;
}

interface MilestoneCreateModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  tenantId: string;
}

export default function MilestoneCreateModal({
  isOpen,
  onClose,
  onSuccess,
  tenantId,
}: MilestoneCreateModalProps) {
  const [tiers, setTiers] = useState<Tier[]>([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    tier_id: '',
    display_order: 1,
    requirements: [] as any[],
    requirement_logic: 'all',
    reward_product_ids: [] as string[],
    reward_message: '',
    is_active: true,
  });

  useEffect(() => {
    if (isOpen) {
      loadTiers();
    }
  }, [isOpen, tenantId]);

  async function loadTiers() {
    const { data } = await supabase
      .from('milestone_tiers')
      .select('*')
      .eq('tenant_id', tenantId)
      .order('display_order');

    if (data) {
      setTiers(data);
      if (data.length > 0 && !formData.tier_id) {
        setFormData(prev => ({ ...prev, tier_id: data[0].id }));
      }
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);

    try {
      const { error } = await supabase.from('milestones').insert({
        tenant_id: tenantId,
        ...formData,
      });

      if (error) throw error;

      // Reset form
      setFormData({
        name: '',
        description: '',
        tier_id: tiers[0]?.id || '',
        display_order: 1,
        requirements: [],
        requirement_logic: 'all',
        reward_product_ids: [],
        reward_message: '',
        is_active: true,
      });

      onSuccess();
      onClose();
    } catch (error: any) {
      console.error('Error creating milestone:', error);
      alert('Error creating milestone: ' + error.message);
    } finally {
      setLoading(false);
    }
  }

  function addRequirement() {
    setFormData(prev => ({
      ...prev,
      requirements: [
        ...prev.requirements,
        { metricId: '', operator: 'gte', targetValue: 0 },
      ],
    }));
  }

  function updateRequirement(index: number, field: string, value: any) {
    const newReqs = [...formData.requirements];
    newReqs[index] = { ...newReqs[index], [field]: value };
    setFormData(prev => ({ ...prev, requirements: newReqs }));
  }

  function removeRequirement(index: number) {
    setFormData(prev => ({
      ...prev,
      requirements: prev.requirements.filter((_, i) => i !== index),
    }));
  }

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen px-4">
        <div className="fixed inset-0 bg-black/50" onClick={onClose}></div>

        <div className="relative bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-2xl w-full p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Create New Milestone
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
                Milestone Name
              </label>
              <input
                type="text"
                required
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="e.g., First Steps"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Description
              </label>
              <textarea
                required
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="e.g., Walk 10,000 steps in a single day"
                rows={3}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Tier
                </label>
                <select
                  required
                  value={formData.tier_id}
                  onChange={(e) => setFormData({ ...formData, tier_id: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                >
                  {tiers.map((tier) => (
                    <option key={tier.id} value={tier.id}>
                      {tier.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Display Order
                </label>
                <input
                  type="number"
                  required
                  min="1"
                  value={formData.display_order}
                  onChange={(e) => setFormData({ ...formData, display_order: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                />
              </div>
            </div>

            {/* Requirements */}
            <div>
              <div className="flex justify-between items-center mb-3">
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                  Requirements
                </label>
                <button
                  type="button"
                  onClick={addRequirement}
                  className="text-sm text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 flex items-center gap-1"
                >
                  <Plus className="w-4 h-4" />
                  Add Requirement
                </button>
              </div>

              {formData.requirements.map((req, index) => (
                <div key={index} className="flex gap-2 mb-2">
                  <input
                    type="text"
                    placeholder="Metric ID"
                    value={req.metricId}
                    onChange={(e) => updateRequirement(index, 'metricId', e.target.value)}
                    className="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
                  />
                  <select
                    value={req.operator}
                    onChange={(e) => updateRequirement(index, 'operator', e.target.value)}
                    className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
                  >
                    <option value="gte">≥</option>
                    <option value="lte">≤</option>
                    <option value="eq">=</option>
                    <option value="gt">&gt;</option>
                    <option value="lt">&lt;</option>
                  </select>
                  <input
                    type="number"
                    placeholder="Target"
                    value={req.targetValue}
                    onChange={(e) => updateRequirement(index, 'targetValue', parseFloat(e.target.value))}
                    className="w-24 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
                  />
                  <button
                    type="button"
                    onClick={() => removeRequirement(index)}
                    className="p-2 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>

            {/* Reward Message */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Reward Message
              </label>
              <input
                type="text"
                value={formData.reward_message}
                onChange={(e) => setFormData({ ...formData, reward_message: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                placeholder="e.g., Congratulations! You unlocked..."
              />
            </div>

            {/* Active Toggle */}
            <div className="flex items-center">
              <input
                type="checkbox"
                id="is_active"
                checked={formData.is_active}
                onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                className="w-4 h-4 text-indigo-600 rounded"
              />
              <label htmlFor="is_active" className="ml-2 text-sm text-gray-700 dark:text-gray-300">
                Active
              </label>
            </div>

            {/* Actions */}
            <div className="flex gap-3 pt-4 border-t border-gray-200 dark:border-gray-700">
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
                {loading ? 'Creating...' : 'Create Milestone'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
